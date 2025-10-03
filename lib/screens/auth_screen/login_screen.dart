import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:social_media_app/cubit/main_cubit/main_cubit.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/utils/dialogs.dart';
import 'package:social_media_app/utils/overlay.dart';
import 'package:social_media_app/utils/validations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main_screen/main_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String route = 'LoginScreen';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return BlocProvider(create: (context) => AuthenticationCubit(context.read<Api>()), child: Theme(data: ThemeData.dark(),child: AuthPage()));
    return BlocProvider(create: (context) => AuthenticationCubit(context.read<Api>()), child: AuthPage());
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final PageController _pageController = PageController(initialPage: 0);
  bool _isLoginPage = true;

  // Controllers
  final _loginUserCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regReTypePassCtrl = TextEditingController();

  // Flags
  bool _isLoginValid = false;
  bool _isRegValid = false;

  late final StreamSubscription<dynamic> _authSub;

  @override
  void initState() {
    super.initState();

    // Supabase auth listener
    final supabase = Supabase.instance.client;
    _authSub = supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        if (!mounted) return;
        Navigator.pop(context);
        // Navigator.of(context).pushReplacementNamed(LoginScreen.route);
        final password = await showInputDialog(
          context,
          title: 'Nhập mật khẩu mới',
          label: 'Mật khẩu mới',
          subTitle: 'Vui lòng nhập mật khẩu mới cho tài khoản của bạn.',
          isPassword: true,
          validator: (v) => validatePassword(v), // use your validatePassword
        );
        if(mounted && password != null) {
          await context.read<AuthenticationCubit>().updatePassword(password);
        }
      }

      if (event == AuthChangeEvent.userUpdated) {
        if (!mounted) return;
        await showNotificationDialog(context, message: 'Change password successfully!');
      }

      debugPrint("Auth event: $event");
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (!mounted) return;
        final provider = (session.user.appMetadata['provider'] ?? '').toString().toLowerCase();
        if(provider == 'facebook') {
          Navigator.pop(context);
        }
        await context.read<AuthenticationCubit>().createUserProfile();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.route, (Route<dynamic> route) => false);
      }
    });

    // các listener text field như trước
    _loginUserCtrl.addListener(_validateLoginForm);
    _loginPassCtrl.addListener(_validateLoginForm);

    _regEmailCtrl.addListener(_validateRegForm);
    _regPassCtrl.addListener(_validateRegForm);
    _regReTypePassCtrl.addListener(_validateRegForm);

    _validateLoginForm();
    _validateRegForm();
  }

  void _goToLogin() {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  void _goToSignup() {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    // hủy subscription để tránh leak
    try {
      _authSub.cancel();
    } catch (_) {}

    _pageController.dispose();

    _loginUserCtrl.removeListener(_validateLoginForm);
    _loginPassCtrl.removeListener(_validateLoginForm);
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();

    _regEmailCtrl.removeListener(_validateRegForm);
    _regPassCtrl.removeListener(_validateRegForm);
    _regReTypePassCtrl.removeListener(_validateRegForm);
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regReTypePassCtrl.dispose();

    super.dispose();
  }

  void _validateLoginForm() {
    final user = _loginUserCtrl.text.trim();
    final pass = _loginPassCtrl.text;
    final isValid = user.isNotEmpty && pass.isNotEmpty;

    if (isValid != _isLoginValid) setState(() => _isLoginValid = isValid);
  }

  void _validateRegForm() {
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text;
    final re = _regReTypePassCtrl.text;

    // dùng hàm validate sẵn của bạn: trả về null khi hợp lệ
    final emailErr = validateEmail(email);
    final passErr = validatePassword(pass);
    final matchErr = pass == re ? null : 'Mật khẩu không khớp';

    final isValid = emailErr == null && passErr == null && matchErr == null;

    if (isValid != _isRegValid) setState(() => _isRegValid = isValid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtleBorder = theme.colorScheme.onSurface.withAlpha(16);

    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.loading) {
          LoadingOverlay.show(context);
        }
        if (state.loadStatus != LoadStatus.loading) {
          LoadingOverlay.hide();
        }
        if (state.loadStatus == LoadStatus.error) {
          showErrorDialog(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        var cubit = context.read<AuthenticationCubit>();
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Text('Pixora', style: TextStyle(fontSize: 42, fontFamily: 'Billabong', color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 275,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) => setState(() => _isLoginPage = index == 0),
                        children: [
                          // Login fields
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AdaptiveTextField(
                                controller: _loginUserCtrl,
                                hint: 'Email hoặc tên người dùng',
                                textInputType: TextInputType.emailAddress,
                                // optional: show quick hint/error, but main disabling logic uses controllers
                                validator: (v) {
                                  if (v.trim().isEmpty) return 'Vui lòng nhập email hoặc tên';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AdaptiveTextField(
                                controller: _loginPassCtrl,
                                hint: 'Mật khẩu',
                                obscureText: true,
                                validator: (v) {
                                  if (v.isEmpty) return 'Vui lòng nhập mật khẩu';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    // TODO: quên mật khẩu
                                    final email = await showInputDialog(
                                      context,
                                      title: 'Quên mật khẩu',
                                      label: 'Email',
                                      subTitle: 'Nhập email của bạn. Chúng tôi sẽ gửi link đặt lại mật khẩu đến email của bạn.',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) => validateEmail(v.trim()), // returns null when valid
                                    );
                                    if (email != null) {
                                      showNotificationDialog(context, message: 'Vui lòng kiểm tra hộp thư email $email để xác nhận.');
                                      await cubit.sentEmailConfirm(email);
                                    }
                                  },
                                  child: const Text('Quên mật khẩu?'),
                                ),
                              ),
                            ],
                          ),

                          // Signup fields
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AdaptiveTextField(
                                controller: _regEmailCtrl,
                                hint: 'Email',
                                textInputType: TextInputType.emailAddress,
                                validator: (v) => validateEmail(v.trim()),
                              ),
                              const SizedBox(height: 12),
                              AdaptiveTextField(controller: _regPassCtrl, hint: 'Mật khẩu', obscureText: true, validator: (v) => validatePassword(v)),
                              const SizedBox(height: 12),
                              AdaptiveTextField(
                                controller: _regReTypePassCtrl,
                                hint: 'Nhập lại mật khẩu',
                                obscureText: true,
                                validator: (v) {
                                  if (v != _regPassCtrl.text) return 'Mật khẩu không khớp';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_isLoginPage) ...[
                      ElevatedButton(
                        onPressed:
                            _isLoginValid
                                ? () {
                                  cubit.signInWithEmail(_loginUserCtrl.text.trim(), _loginPassCtrl.text);
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: subtleBorder),
                        ),
                        child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed:
                            _isRegValid
                                ? () async {
                                  cubit.signUpWithEmail(_regEmailCtrl.text.trim(), _regPassCtrl.text);
                                  await showEmailConfirmationDialog(context, email: _regEmailCtrl.text);
                                  _goToLogin();
                                  setState(() {
                                    _loginUserCtrl.text = _regEmailCtrl.text;
                                    _loginPassCtrl.text = _regPassCtrl.text;
                                  });
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: subtleBorder),
                        ),
                        child: const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('HOẶC')),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Google (no border)
                    ElevatedButton.icon(
                      onPressed: () async {
                        // TODO: tích hợp google sign-in
                        await cubit.loginWithGoogle();
                      },
                      icon: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Text('G', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Đăng nhập bằng Google', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Facebook
                    ElevatedButton.icon(
                      onPressed: () async {
                        // TODO: tích hợp facebook sign-in
                        await cubit.loginWithFacebook();
                      },
                      icon: const Icon(Icons.facebook, size: 18, color: Colors.white),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Đăng nhập bằng Facebook', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    // Bottom: đổi giữa login <-> signup
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_isLoginPage ? 'Chưa có tài khoản?' : 'Đã có tài khoản?'),
                          TextButton(
                            onPressed: _isLoginPage ? _goToSignup : _goToLogin,
                            child: Text(_isLoginPage ? 'Đăng ký' : 'Đăng nhập', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String subTitle,
    bool isPassword = false,
    String? Function(String)? validator, // return null when valid
    TextInputType keyboardType = TextInputType.text,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _SingleInputDialog(title: title, label: label, subTitle: subTitle, isPassword: isPassword, validator: validator, keyboardType: keyboardType);
      },
    );
  }
}

class AdaptiveTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final String? Function(String value)? validator;
  final void Function(String)? onSubmitted;

  const AdaptiveTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onSubmitted,
    super.key,
  });

  @override
  State<AdaptiveTextField> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  late FocusNode _focusNode;
  bool _focused = false;
  late bool _obscure; // toggle for password
  String? errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
    _obscure = widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final Color bgUnfocused = cs.surfaceContainerHighest;
    final Color bgFocused = cs.primary.withAlpha(25);
    final Color background = _focused ? bgFocused : bgUnfocused;

    final Color unfocusBorder = cs.onSurface.withAlpha(30);
    final Color focusBorder = cs.primary;

    final TextStyle? textStyle = theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface);
    final TextStyle? hintStyle = theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant.withAlpha(192));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _focused ? focusBorder : unfocusBorder, width: _focused ? 1.4 : 1.0),
        boxShadow: _focused ? [BoxShadow(color: cs.primary.withAlpha(30), blurRadius: 8, offset: const Offset(0, 3))] : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              keyboardType: widget.textInputType,
              obscureText: _obscure,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              style: textStyle,
              onChanged: (value) {
                setState(() {
                  errorText = widget.validator?.call(value);
                });
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: hintStyle,
                border: InputBorder.none,
                errorText: errorText,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              ),
              cursorColor: cs.primary,
            ),
          ),

          // Toggle password
          if (widget.obscureText)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                splashRadius: 20,
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: _focused ? cs.primary : theme.iconTheme.color),
              ),
            ),
        ],
      ),
    );
  }
}

class _SingleInputDialog extends StatefulWidget {
  final String title;
  final String label;
  final String subTitle;
  final bool isPassword;
  final String? Function(String)? validator;
  final TextInputType keyboardType;

  const _SingleInputDialog({
    required this.title,
    required this.label,
    required this.subTitle,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_SingleInputDialog> createState() => _SingleInputDialogState();
}

class _SingleInputDialogState extends State<_SingleInputDialog> {
  late final TextEditingController _controller;
  String? _error;
  bool _valid = false;
  bool _obscureText = true; // mặc định ẩn

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (!widget.isPassword) {
      _obscureText = false; // nếu không phải password thì hiển thị bình thường
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final err = widget.validator?.call(v.trim());
    setState(() {
      _error = null; // chỉ hiển thị lỗi khi submit
      _valid = err == null;
    });
  }

  void _submit() {
    final value = _controller.text.trim();
    final err = widget.validator?.call(value);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.subTitle),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              decoration: InputDecoration(
                labelText: widget.label,
                errorText: _error,
                suffixIcon: widget.isPassword
                    ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                    : null,
              ),
              onChanged: _onChanged,
              onSubmitted: (_) {
                if (_valid) _submit();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('CANCEL')),
        TextButton(onPressed: _valid ? _submit : null, child: const Text('OK')),
      ],
    );
  }
}