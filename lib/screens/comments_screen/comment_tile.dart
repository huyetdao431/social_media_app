import 'package:flutter/material.dart';

class CommentTile extends StatefulWidget {
  final String username;
  final String caption;
  final int likesCount;
  final VoidCallback? onReply;
  final VoidCallback? onAvatarTap;
  final int depth;
  final int maxDepth;
  final String? time;

  const CommentTile({
    required this.username,
    required this.caption,
    this.likesCount = 0,
    this.onReply,
    this.onAvatarTap,
    this.depth = 0,
    this.maxDepth = 2,
    this.time = '1h',
    super.key,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool showReplies = false;

  final int _replyCount = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(left: widget.depth == 0 ? 0 : 40, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar
          GestureDetector(
            onTap: widget.onAvatarTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: Text(widget.username.substring(0, 1).toUpperCase(), style: TextStyle(color: theme.colorScheme.onPrimary)),
            ),
          ),
          const SizedBox(width: 10),
          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // username + caption
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.username,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.time != null)
                      Text(
                        widget.time!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withAlpha(150)),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // hàng dưới: comment text (caption)
                Text(
                  widget.caption,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                ),

                const SizedBox(height: 8),

                // action row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) {
                          return ScaleTransition(scale: anim, child: child);
                        },
                        child:
                            isLiked
                                ? Icon(Icons.favorite, key: const ValueKey('liked'), color: Colors.red, size: 20)
                                : const Icon(Icons.favorite_border, key: ValueKey('unliked'), size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${widget.likesCount}'),
                    const SizedBox(width: 16),
                    GestureDetector(onTap: widget.onReply, child: Text('Reply', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))),

                    if (widget.depth < widget.maxDepth && _replyCount > 0)
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showReplies = !showReplies;
                              });
                            },
                            child: Text(showReplies ? 'Hide $_replyCount replies' : 'Show $_replyCount replies'),
                          ),
                        ],
                      ),
                  ],
                ),

                Visibility(
                  visible: showReplies && widget.depth < widget.maxDepth,
                  maintainState: false,
                  child: Column(
                    children: [
                      for (var i = 0; i < _replyCount; i++)
                        CommentTile(
                          username: '${widget.username}_rep$i',
                          caption: 'Reply #$i to ${widget.username}',
                          likesCount: i,
                          depth: widget.depth + 1,
                          maxDepth: widget.maxDepth,
                          onReply: () => widget.onReply?.call(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
