import 'package:flutter/material.dart';
import 'package:social_media_app/utils/loader/comment_skeleton_loader.dart';

import 'comment_tile.dart';

class CommentsModal extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<String> onSend;

  const CommentsModal({required this.scrollController, required this.onSend, super.key});

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final bool _autofocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_autofocus) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleReplyTo(String username) {
    final mention = '@$username ';
    _controller.text = mention;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    _focusNode.requestFocus();

    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = 16.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12, // tránh keyboard
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
            ),

            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comments', style: theme.textTheme.titleMedium),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),

            const SizedBox(height: 8),

            // list comments
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                itemCount: 15,
                itemBuilder: (context, index) {
                  final username = 'user$index';
                  return index %2 == 0 ? CommentTile(
                    username: username,
                    caption: 'Đây là nội dung bình luận số $index. Nội dung có thể dài nhiều dòng để test ExpandableCaption.',
                    likesCount: 100 + index,
                    onReply: () => _handleReplyTo(username),
                    onAvatarTap: () {
                      // todo: chuyển đến profile khi cần
                    },
                  ) : CommentTileSkeleton();
                },
              ),
            ),

            const SizedBox(height: 8),

            // input row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withAlpha(30),
                  child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Thêm bình luận...',
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _send, icon: Icon(Icons.send, color: theme.colorScheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}