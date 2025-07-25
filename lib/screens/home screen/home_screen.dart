import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String route = 'HomeScreen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(route),);
  }
}
