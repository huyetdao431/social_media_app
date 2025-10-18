part of 'comment_bloc.dart';

abstract class CommentEvent {}

class CreateComment extends CommentEvent {
  final String targetType;
  final String targetId;
  final String userId;
  final String content; 
  CreateComment({required this.targetType, required this.targetId, required this.userId, required this.content});
}

class CreateReply extends CommentEvent {
  final String targetType;
  final String targetId;
  final String userId;
  final String content;
  final String parentId;
  CreateReply({required this.targetType, required this.targetId, required this.userId, required this.content, required this.parentId});
}

class GetComments extends CommentEvent {
  final String targetType;
  final String targetId;
  final int limit;
  final int offset;
  GetComments({required this.targetType, required this.targetId, this.limit = 20, this.offset = 0});
}

class GetReplies extends CommentEvent {
  final String commentId;
  final int limit;
  GetReplies({required this.commentId, this.limit = 5});
}

class UpdateComment extends CommentEvent {
  final String commentId;
  final String userId;
  final String newContent;
  UpdateComment({required this.commentId, required this.userId, required this.newContent});
}

class DeleteComment extends CommentEvent {
  final String commentId;
  final String userId;
  DeleteComment({required this.commentId, required this.userId});
}