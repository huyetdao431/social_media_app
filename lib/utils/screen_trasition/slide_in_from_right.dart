import 'package:flutter/material.dart';

PageRouteBuilder slideInFromRight(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
      final offsetAnimation = animation.drive(tween);

      const beginSecondary = Offset.zero;
      const endSecondary = Offset(-0.3, 0.0);
      final secondaryTween = Tween(begin: beginSecondary, end: endSecondary).chain(CurveTween(curve: Curves.easeInOut));
      final secondaryOffsetAnimation = secondaryAnimation.drive(secondaryTween);

      return SlideTransition(position: offsetAnimation, child: SlideTransition(position: secondaryOffsetAnimation, child: child));
    },
  );
}
