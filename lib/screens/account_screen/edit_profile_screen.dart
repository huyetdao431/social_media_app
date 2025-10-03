import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/utils/dialogs.dart';
import 'package:social_media_app/utils/overlay.dart';

import '../../cubit/profile_cubit/profile_cubit.dart';
import '../../models/profile/profiles.dart';

class EditProfileScreen extends StatelessWidget {
  static const String route = 'EditProfileScreen';

  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.userProfile;
        if (profile == null) {
          // loading / no profile yet
          return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor, body: const Center(child: CircularProgressIndicator()));
        }

        return _EditProfileForm(initialProfile: profile);
      },
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final Profile initialProfile;

  const _EditProfileForm({required this.initialProfile});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;

  late bool _isPublic;
  Timer? _debounce;

  File? _avatarFile;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  // limits
  static const int _usernameLimitDays = 30;
  static const int _displayNameLimitDays = 7;

  // NEW: username checking state
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;
  String? _usernameCheckError;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _usernameController = TextEditingController(text: p.username);
    _displayNameController = TextEditingController(text: p.displayName ?? '');
    _bioController = TextEditingController(text: p.bio ?? '');
    _isPublic = p.isPublic;
    _avatarUrl = p.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
        _avatarUrl = null; // prefer the local picked file
      });
    }
  }

  void _showPickOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Xóa ảnh đại diện'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _avatarFile = null;
                      _avatarUrl = null;
                    });
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAvatar(double size) {
    final radius = size / 2;
    if (_avatarFile != null) {
      return CircleAvatar(radius: radius, backgroundColor: Theme.of(context).colorScheme.surface, backgroundImage: FileImage(_avatarFile!));
    }
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: Theme.of(context).colorScheme.surface, backgroundImage: NetworkImage(_avatarUrl!));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Icon(Icons.person, size: radius, color: Theme.of(context).textTheme.bodyLarge?.color),
    );
  }

  int? _daysLeft(DateTime? changedAt, int limitDays, DateTime? createAt) {
    if (changedAt == null) return null;
    if (changedAt != createAt) {
      final now = DateTime.now();
      final changed = changedAt.toLocal();
      final daysSince = now.difference(changed).inDays;
      final daysLeft = limitDays - daysSince;
      if (daysLeft > 0) return daysLeft;
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // prevent save when username is known taken
    if (_isUsernameAvailable == false) {
      showNotificationDialog(context, message: 'Tên đăng nhập đã có người sử dụng. Vui lòng chọn tên khác.', title: 'Lỗi');
      return;
    }

    // if availability is unknown and username changed, ask user to wait/check
    final newUsername = _usernameController.text.trim();
    if (_isUsernameAvailable == null && newUsername != widget.initialProfile.username) {
      showNotificationDialog(context, message: 'Vui lòng chờ hệ thống kiểm tra tên đăng nhập trước khi lưu.', title: 'Đang kiểm tra');
      return;
    }

    String? uploadedUrl;
    if (_avatarFile != null) {
      // TODO: nếu _avatarFile != null thì upload avatar và lấy avatarUrl trả về từ server.
      uploadedUrl = await context.read<ProfileCubit>().uploadAvatar(_avatarFile!);
    }

    final old = widget.initialProfile;

    final updated = old.copyWith(
      username: _usernameController.text.trim(),
      displayName: _displayNameController.text.trim().isEmpty ? null : _displayNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      isPublic: _isPublic,
      avatarUrl: uploadedUrl ?? old.avatarUrl,
      usernameChangedAt: _usernameController.text.trim() == old.username ? DateTime.now() : old.usernameChangedAt,
      displayNameChangedAt: _displayNameController.text.trim() == old.displayName ? DateTime.now() : old.displayNameChangedAt,
    );
    if (!mounted) return;
    context.read<ProfileCubit>().updateProfile(updated);
  }

  // NEW: onChanged with debounce
  void onUsernameChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchResults(query);
    });

    setState(() {
      _isUsernameAvailable = null;
      _usernameCheckError = null;
    });
  }

  // NEW: actual check
  Future<void> fetchResults(String username) async {
    final u = username.trim();
    if (u.isEmpty) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = null;
        _usernameCheckError = null;
      });
      return;
    }

    // if user didn't change username (still original) -> consider available
    if (u == widget.initialProfile.username) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = true;
        _usernameCheckError = null;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameAvailable = null;
      _usernameCheckError = null;
    });

    try {
      final available = await context.read<ProfileCubit>().checkUsername(u);

      if (!mounted) return;
      setState(() {
        _isUsernameAvailable = available;
        _isCheckingUsername = false;
        _usernameCheckError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = false;
        _usernameCheckError = 'Không thể kiểm tra tên đăng nhập. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final avatarSize = width * 0.28;

    final usernameDaysLeft = _daysLeft(widget.initialProfile.usernameChangedAt, _usernameLimitDays, widget.initialProfile.createdAt);
    final displayNameDaysLeft = _daysLeft(widget.initialProfile.displayNameChangedAt, _displayNameLimitDays, widget.initialProfile.createdAt);

    final canEditUsername = usernameDaysLeft == null;
    final canEditDisplayName = displayNameDaysLeft == null;

    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) async{
        if (state.loadStatus == LoadStatus.loading) {
          LoadingOverlay.show(context);
        }
        if (state.loadStatus != LoadStatus.loading) {
          LoadingOverlay.hide();
        }
        if (state.loadStatus == LoadStatus.done && state.errorMessage.isNotEmpty) {
          final result = await showNotificationDialog(context, message: 'Cập nhật profile thành công!', title: 'Thành công');
          if(result! && context.mounted) {
            Navigator.of(context).pop();
          }
        }
        if (state.loadStatus == LoadStatus.error) {
          showNotificationDialog(context, message: state.errorMessage, title: 'Lỗi');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chỉnh sửa trang cá nhân', style: theme.textTheme.headlineLarge),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: theme.appBarTheme.iconTheme,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar + action (no Card wrapper)
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [theme.colorScheme.primary.withAlpha(30), Colors.transparent]),
                            ),
                            child: _buildAvatar(avatarSize),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _showPickOptions,
                              child: Container(
                                decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt, size: 18, color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _showPickOptions, child: Text('Thay đổi ảnh đại diện', style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Form fields (no Card)
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // USERNAME: pass isUsernameField: true and onChanged
                      _buildTextField(
                        label: 'Tên đăng nhập',
                        hint: 'username',
                        controller: _usernameController,
                        prefix: Icons.alternate_email,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên đăng nhập';
                          final simple = RegExp(r'^[a-z0-9._]+$');
                          if (!simple.hasMatch(v)) return 'Chỉ cho phép chữ thường, số, dấu . và _';

                          // prevent submit if known taken
                          if (_isUsernameAvailable == false) return 'Tên đăng nhập đã được sử dụng';
                          // if unknown and changed from original -> force wait
                          if (_isUsernameAvailable == null && v.trim() != widget.initialProfile.username) return 'Vui lòng chờ kiểm tra tên đăng nhập';
                          return null;
                        },
                        onChanged: onUsernameChanged,
                        isUsernameField: true,
                        enabled: canEditUsername,
                      ),

                      // username note based on last change
                      const SizedBox(height: 6),
                      if (usernameDaysLeft != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                          child: Text(
                            'Bạn còn $usernameDaysLeft ngày để đổi tên đăng nhập (hạn: $_usernameLimitDays ngày kể từ lần đổi gần nhất).',
                            style: theme.textTheme.bodySmall?.copyWith(color: onSurface.withAlpha(179)),
                          ),
                        ),

                      const SizedBox(height: 8),

                      _buildTextField(
                        label: 'Tên hiển thị',
                        hint: 'Tên của bạn',
                        controller: _displayNameController,
                        prefix: Icons.person,
                        enabled: canEditDisplayName,
                      ),

                      // displayName note
                      const SizedBox(height: 6),
                      if (displayNameDaysLeft != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                          child: Text(
                            'Bạn còn $displayNameDaysLeft ngày để đổi tên hiển thị (hạn: $_displayNameLimitDays ngày).',
                            style: theme.textTheme.bodySmall?.copyWith(color: onSurface.withAlpha(179)),
                          ),
                        ),

                      const SizedBox(height: 8),

                      _buildTextField(label: 'Tiểu sử', hint: 'Viết một vài điều về bạn', controller: _bioController, maxLines: 3, prefix: Icons.edit),

                      const SizedBox(height: 12),

                      SwitchListTile(
                        title: const Text('Công khai tài khoản'),
                        subtitle: const Text('Cho phép người khác xem các bài viết, tin của bạn'),
                        value: _isPublic,
                        onChanged: (v) => setState(() => _isPublic = v),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Lưu thay đổi', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                      ),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: () {
                          // show a dialog to confirm logout / switch account
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Chuyển tài khoản'),
                                  content: const Text('Bạn có muốn chuyển sang tài khoản khác?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        // TODO: implement logout and navigation
                                      },
                                      child: const Text('Đăng xuất'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Text('Chuyển sang tài khoản khác', style: theme.textTheme.bodyMedium),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    IconData? prefix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    void Function(String)? onChanged,
    bool isUsernameField = false,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    Widget? suffixIcon;
    if (!enabled) {
      suffixIcon = const Icon(Icons.lock);
    } else if (isUsernameField) {
      if (_isCheckingUsername) {
        suffixIcon = SizedBox(width: 24, height: 24, child: Padding(padding: const EdgeInsets.all(6.0), child: CircularProgressIndicator(strokeWidth: 2)));
      } else if (_isUsernameAvailable == true) {
        suffixIcon = Icon(Icons.check_circle, color: Colors.green);
      } else if (_isUsernameAvailable == false) {
        suffixIcon = Icon(Icons.error, color: Colors.red);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: theme.textTheme.bodyLarge,
          onChanged: enabled ? onChanged : null,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: prefix != null ? Icon(prefix, color: theme.iconTheme.color) : null,
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            suffixIcon: suffixIcon,
          ),
        ),

        if (isUsernameField)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 6.0),
            child: Builder(
              builder: (_) {
                if (_isCheckingUsername) {
                  return Text('Đang kiểm tra tên đăng nhập...', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(160)));
                }
                if (_usernameCheckError != null) {
                  return Text(_usernameCheckError!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.red));
                }
                if (!enabled) {
                  return const SizedBox.shrink();
                }
                if (_isUsernameAvailable == true) {
                  return Text('Tên đăng nhập khả dụng', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green));
                }
                if (_isUsernameAvailable == false) {
                  return Text('Tên đăng nhập đã được sử dụng', style: theme.textTheme.bodySmall?.copyWith(color: Colors.red));
                }
                return const SizedBox.shrink();
              },
            ),
          ),

        if (!isUsernameField && !enabled) Padding(padding: const EdgeInsets.only(left: 8.0, top: 6.0), child: const SizedBox.shrink()),
      ],
    );
  }
}
