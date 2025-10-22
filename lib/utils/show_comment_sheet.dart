import 'package:flutter/material.dart';

import '../screens/comments_screen/comment_screen.dart';

void showCommentsModal(BuildContext context, {required String targetType, required String targetId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return CommentsModal(scrollController: scrollController, targetType: targetType, targetId: targetId);
        },
      );
    },
  );
}