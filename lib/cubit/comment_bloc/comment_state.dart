part of 'comment_bloc.dart';

class CommentState {
  final LoadStatus loadStatus;
  final Map<String, LoadStatus> replyLoadStatus;
  final LoadStatus loadCommentStatus;
  final List<Comment> comments;
  final Map<String, List<Comment>> replies;
  final Comment? userComment;
  final String postId;
  final String errorMessage;

  const CommentState.init({
    this.loadStatus = LoadStatus.init,
    this.replyLoadStatus = const {},
    this.loadCommentStatus = LoadStatus.init,
    this.comments = const [],
    this.replies = const {},
    this.userComment,
    this.postId = '',
    this.errorMessage = '',
  });

  //<editor-fold desc="Data Methods">
  const CommentState({
    required this.loadStatus,
    required this.replyLoadStatus,
    required this.loadCommentStatus,
    required this.comments,
    required this.replies,
    this.userComment,
    required this.postId,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          replyLoadStatus == other.replyLoadStatus &&
          loadCommentStatus == other.loadCommentStatus &&
          comments == other.comments &&
          replies == other.replies &&
          userComment == other.userComment &&
          postId == other.postId &&
          errorMessage == other.errorMessage);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      replyLoadStatus.hashCode ^
      loadCommentStatus.hashCode ^
      comments.hashCode ^
      replies.hashCode ^
      userComment.hashCode ^
      postId.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'CommentState{' +
        ' loadStatus: $loadStatus,' +
        ' replyLoadStatus: $replyLoadStatus,' +
        ' loadCommentStatus: $loadCommentStatus,' +
        ' comments: $comments,' +
        ' replies: $replies,' +
        ' userComment: $userComment,' +
        ' postId: $postId,' +
        ' errorMessage: $errorMessage,' +
        '}';
  }

  CommentState copyWith({
    LoadStatus? loadStatus,
    Map<String, LoadStatus>? replyLoadStatus,
    LoadStatus? loadCommentStatus,
    List<Comment>? comments,
    Map<String, List<Comment>>? replies,
    Comment? userComment,
    String? postId,
    String? errorMessage,
  }) {
    return CommentState(
      loadStatus: loadStatus ?? this.loadStatus,
      replyLoadStatus: replyLoadStatus ?? this.replyLoadStatus,
      loadCommentStatus: loadCommentStatus ?? this.loadCommentStatus,
      comments: comments ?? this.comments,
      replies: replies ?? this.replies,
      userComment: userComment ?? this.userComment,
      postId: postId ?? this.postId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'replyLoadStatus': this.replyLoadStatus,
      'loadCommentStatus': this.loadCommentStatus,
      'comments': this.comments,
      'replies': this.replies,
      'userComment': this.userComment,
      'postId': this.postId,
      'errorMessage': this.errorMessage,
    };
  }

  factory CommentState.fromMap(Map<String, dynamic> map) {
    return CommentState(
      loadStatus: map['loadStatus'] as LoadStatus,
      replyLoadStatus: map['replyLoadStatus'] as Map<String, LoadStatus>,
      loadCommentStatus: map['loadCommentStatus'] as LoadStatus,
      comments: map['comments'] as List<Comment>,
      replies: map['replies'] as Map<String, List<Comment>>,
      userComment: map['userComment'] as Comment,
      postId: map['postId'] as String,
      errorMessage: map['errorMessage'] as String,
    );
  }

  //</editor-fold>
}