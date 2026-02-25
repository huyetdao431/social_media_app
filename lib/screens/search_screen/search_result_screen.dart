import 'package:flutter/material.dart';

class SearchResultScreen extends StatefulWidget {
  static const String route = 'SearchResultScreen';
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Container()));
  }
}
