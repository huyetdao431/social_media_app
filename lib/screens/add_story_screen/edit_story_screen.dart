import 'package:flutter/material.dart';

class EditStoryScreen extends StatelessWidget {
  static const String route = 'EditStoryScreen';
  const EditStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

