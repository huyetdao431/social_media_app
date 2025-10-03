import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/auth_screen/login_screen.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';

import '../../services/repositories/shared_preference_repository.dart';

class SplashScreen extends StatelessWidget {
  static const String route = 'SplashScreen';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SplashPage();
  }
}

class _SplashPage extends StatefulWidget {
  const _SplashPage();

  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Logo animation (fade + scale like Instagram)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Delay a little before checking login
    Timer(const Duration(seconds: 1), _checkLogin);
  }

  Future<void> _checkLogin() async {
    final loggedIn = await SharedPreferenceRepository.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.of(context).pushReplacementNamed(MainScreen.route);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.route);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: _LogoAnimation(),
      ),
    );
  }
}

class _LogoAnimation extends StatelessWidget {
  const _LogoAnimation();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_SplashPageState>()!;
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: state._controller, curve: Curves.easeInOut),
      ),
      child: FadeTransition(
        opacity: state._animation,
        child: Image.asset(
          'assets/app_icon/app_icon.png', // your logo in assets
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
