import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../commons/widgets/post.dart';

class PostListScreen extends StatelessWidget {
  static const String route = 'PostListScreen';
  final int initialIndex;
  final List<Post> posts = List.filled(5, Post());

  PostListScreen({super.key, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final itemScrollController = ItemScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController.scrollTo(
        index: initialIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: ScrollablePositionedList.builder(
        itemCount: posts.length,
        itemScrollController: itemScrollController,
        itemBuilder: (context, index) => posts[index],
      ),
    );
  }
}
