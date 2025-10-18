import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/comment_bloc/comment_bloc.dart';
import 'package:social_media_app/cubit/main_cubit/main_cubit.dart';
import 'package:social_media_app/utils/dialogs.dart';
import 'package:social_media_app/utils/loader/comment_skeleton_loader.dart';
import 'package:social_media_app/utils/user_avatar.dart';
import '../../models/comment.dart';
import '../../services/repositories/api/api.dart';
import 'comment_tile.dart';

class CommentsModal extends StatelessWidget {
  final ScrollController scrollController;
  final String targetId;
  final String targetType;

  const CommentsModal({required this.scrollController, super.key, required this.targetType, required this.targetId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentBloc(context.read<Api>())..add(GetComments(targetType: 'post', targetId: targetId)),
      child: CommentPage(scrollController: scrollController),
    );
  }
}

class CommentPage extends StatefulWidget {
  final ScrollController scrollController;

  const CommentPage({super.key, required this.scrollController});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final bool _autofocus = false;
  bool isReply = false;
  String parentId = '';

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

  void _handleReplyTo(Comment comment) {
    final mention = '@${comment.userDisplayName} ';
    _controller.text = mention;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    _focusNode.requestFocus();
    setState(() {
      isReply = true;
      parentId = comment.id;
    });

    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(widget.scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    var bloc = context.read<CommentBloc>();
    if(isReply) {
      bloc.add(CreateReply(targetType: 'post',targetId: bloc.state.postId, userId: context.read<MainCubit>().state.profile!.id, content: text, parentId: parentId));
    } else {
      bloc.add(CreateComment(targetType: 'post',targetId: bloc.state.postId, userId: context.read<MainCubit>().state.profile!.id, content: text));
    }
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        // TODO: implement listener
        if(state.loadStatus == LoadStatus.error) {
          showErrorDialog(context, 'Lỗi khi thêm bình luận, vui lòng thử lại sau!');
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final radius = 16.0;
        var bloc = context.read<CommentBloc>();
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
          ),
          padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 12),
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
                  child:
                      bloc.state.loadStatus == LoadStatus.loading
                          ? ListView.builder(
                            controller: widget.scrollController,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return CommentTileSkeleton();
                            },
                          )
                          : ListView.builder(
                            controller: widget.scrollController,
                            itemCount: bloc.state.comments.length + (bloc.state.loadCommentStatus == LoadStatus.loading ? 1 : 0),
                            itemBuilder: (context, index) {
                              var isLoading = bloc.state.loadCommentStatus == LoadStatus.loading;
                              if (index == 0 && isLoading) {
                                return CommentTileSkeleton();
                              }
                              final adjustedIndex = isLoading ? index - 1 : index;
                              final comment = bloc.state.comments[adjustedIndex];
                              return CommentTile(
                                index: adjustedIndex,
                                onReply: () => _handleReplyTo(comment),
                              );
                            },
                          ),
                ),

                const SizedBox(height: 8),

                // input row
                Row(
                  children: [
                    userAvatar(context.read<MainCubit>().state.profile!.avatarUrl),
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
      },
    );
  }
}
