import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/utils/loader/comment_skeleton_loader.dart';
import 'package:social_media_app/commons/widgets/user_avatar.dart';

import '../../cubit/comment_bloc/comment_bloc.dart';
import '../../utils/time_ago.dart';

class CommentTile extends StatefulWidget {
  final int index;
  final String? parentId;
  final VoidCallback? onReply;
  final int depth;
  final int maxDepth;

  const CommentTile({required this.index, this.parentId, this.onReply, this.depth = 0, this.maxDepth = 1, super.key});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool showReplies = false;

  @override
  Widget build(BuildContext context) {
    print('DEBUG: parentId: ${widget.parentId}');
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        var bloc = context.read<CommentBloc>();
        final comment = widget.depth == 0 ? bloc.state.comments[widget.index] : bloc.state.replies[widget.parentId]![widget.index];
        final replies = state.replies[comment.id] ?? [];
        final replyStatus = state.replyLoadStatus[comment.id] ?? LoadStatus.init;
        return Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              GestureDetector(
                onTap: () {
                  //todo: go to user profile screen
                },
                child: userAvatar(comment.userAvatarUrl!),
              ),
              const SizedBox(width: 10),

              // Nội dung comment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.userDisplayName ?? 'Người dùng',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(timeAgo(comment.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(comment.content, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
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
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child:
                                isLiked
                                    ? Icon(Icons.favorite, key: const ValueKey('liked'), color: Colors.red, size: 20)
                                    : const Icon(Icons.favorite_border, key: ValueKey('unliked'), size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${comment.likeCount + (isLiked ? 1 : 0)}'),
                        const SizedBox(width: 16),
                        GestureDetector(onTap:() {
                          widget.onReply!();
                          setState(() {
                            showReplies = true;
                          });
                        }, child: Text('Reply', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor))),
                        if (widget.depth < widget.maxDepth && comment.replyCount > 0)
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    showReplies = !showReplies;
                                  });
                                  if (!bloc.state.replies.containsKey(comment.id)) {
                                    bloc.add(GetReplies(commentId: comment.id));
                                  }
                                },
                                child: Text(showReplies
                                    ? 'Hide ${comment.replyCount} replies'
                                    : 'Show ${comment.replyCount} replies'),
                              ),
                            ],
                          ),
                      ],
                    ),

                    if (showReplies && widget.depth < widget.maxDepth)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Builder(
                          builder: (context) {
                            if (replyStatus == LoadStatus.loading && replies.isEmpty) {
                              return const CommentTileSkeleton(depth: 1);
                            }
                            return Column(
                              children: [
                                for (var i = 0; i < replies.length; i++)
                                  CommentTile(
                                    index: i,
                                    parentId: comment.id,
                                    depth: widget.depth + 1,
                                    maxDepth: widget.maxDepth,
                                    onReply: widget.onReply,
                                  ),
                                if (replyStatus == LoadStatus.loading)
                                  const CommentTileSkeleton(depth: 1),
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
