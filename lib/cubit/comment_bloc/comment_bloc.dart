import 'package:bloc/bloc.dart';
import 'package:social_media_app/models/comment.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

import '../../commons/enums/load_status.dart';

part 'comment_event.dart';

part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  Api api;

  CommentBloc(this.api) : super(CommentState.init()) {
    on<CreateComment>(_createComment);
    on<CreateReply>(_createReply);
    on<GetComments>(_getComments);
    on<GetReplies>(_getReplies);
    on<UpdateComment>(_updateComment);
    on<DeleteComment>(_deleteComment);
  }

  Future<void> _createComment(CreateComment event, Emitter<CommentState> emit) async {
    emit(state.copyWith(loadCommentStatus : LoadStatus.loading));
    try {
      print('DEBUG: postId=${event.postId}, userId=${event.userId}');
      final comment = await api.createComment(postId: event.postId, userId: event.userId, content: event.content);
      final updatedComment = List<Comment>.from(state.comments);
      updatedComment.insert(0, comment);
      emit(state.copyWith(loadCommentStatus : LoadStatus.done, userComment: comment, comments: updatedComment));
    } catch (e) {
      emit(state.copyWith(loadCommentStatus : LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _createReply(CreateReply event, Emitter<CommentState> emit) async {
    emit(state.copyWith(loadReplyStatus: LoadStatus.loading));
    try {
      print('DEBUG: postId: ${event.postId}');
      print('DEBUG: parentId: ${event.parentId}');
      print('DEBUG: content: ${event.content}');
      print('DEBUG: userId: ${event.userId}');
      final comment = await api.createComment(postId: event.postId, userId: event.userId, content: event.content, parentId: event.parentId);
      final updatedReplies = Map<String, List<Comment>>.from(state.replies);
      updatedReplies[event.parentId]!.insert(0, comment);
      emit(state.copyWith(loadReplyStatus: LoadStatus.done, userComment: comment, replies: updatedReplies));
    } catch (e) {
      emit(state.copyWith(loadReplyStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _getComments(GetComments event, Emitter<CommentState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      print('init postId: ${event.postId}');
      final comments = await api.getComments(postId: event.postId, limit: event.limit, offset: event.offset);
      emit(state.copyWith(loadStatus: LoadStatus.done, comments: comments, postId: event.postId));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _getReplies(GetReplies event, Emitter<CommentState> emit) async {
    emit(state.copyWith(loadReplyStatus: LoadStatus.loading));
    try {
      final replies = await api.getReplies(commentId: event.commentId, limit: event.limit);
      final currentReplies = Map<String, List<Comment>>.from(state.replies);
      if (currentReplies.keys.contains(event.commentId)) {
        currentReplies[event.commentId]?.addAll(replies);
      } else {
        currentReplies[event.commentId] = replies;
      }
      emit(state.copyWith(loadReplyStatus: LoadStatus.done, replies: currentReplies));
    } catch (e) {
      emit(state.copyWith(loadReplyStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _updateComment(UpdateComment event, Emitter<CommentState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final comment = await api.updateComment(commentId: event.commentId, userId: event.userId, newContent: event.newContent);
      emit(state.copyWith(loadStatus: LoadStatus.done, userComment: comment));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<bool> _deleteComment(DeleteComment event, Emitter<CommentState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final result = await api.deleteComment(commentId: event.commentId, userId: event.userId);
      emit(state.copyWith(loadStatus: LoadStatus.done));
      return result;
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }
}
