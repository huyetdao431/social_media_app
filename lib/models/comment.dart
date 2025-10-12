class Comment {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int replyCount;
  final int likeCount;
  final String? userDisplayName;
  final String? userAvatarUrl;

  //<editor-fold desc="Data Methods">
  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.replyCount,
    required this.likeCount,
    this.userDisplayName,
    this.userAvatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          userId == other.userId &&
          parentId == other.parentId &&
          content == other.content &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          replyCount == other.replyCount &&
          likeCount == other.likeCount &&
          userDisplayName == other.userDisplayName &&
          userAvatarUrl == other.userAvatarUrl);

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      userId.hashCode ^
      parentId.hashCode ^
      content.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      replyCount.hashCode ^
      likeCount.hashCode ^
      userDisplayName.hashCode ^
      userAvatarUrl.hashCode;

  @override
  String toString() {
    return 'Comment{' +
        ' id: $id,' +
        ' postId: $postId,' +
        ' userId: $userId,' +
        ' parentId: $parentId,' +
        ' content: $content,' +
        ' createdAt: $createdAt,' +
        ' updatedAt: $updatedAt,' +
        ' replyCount: $replyCount,' +
        ' likeCount: $likeCount,' +
        ' userDisplayName: $userDisplayName,' +
        ' userAvatarUrl: $userAvatarUrl,' +
        '}';
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    final userMap = map['profiles'] as Map<String, dynamic>?;
    return Comment(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      parentId: map['parent_id'] as String?,
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
      replyCount: (map['reply_count'] is int) ? map['reply_count'] as int : int.tryParse('${map['reply_count'] ?? 0}') ?? 0,
      likeCount: (map['like_count'] is int) ? map['like_count'] as int : int.tryParse('${map['like_count'] ?? 0}') ?? 0,
      userDisplayName: userMap != null ? (userMap['display_name'] ?? userMap['full_name'] ?? userMap['name']) as String? : null,
      userAvatarUrl: userMap != null ? (userMap['avatar_url'] ?? userMap['avatar'] ?? userMap['photo_url']) as String? : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reply_count': replyCount,
      'like_count': likeCount,
      // Note: user fields are not saved into comments table in this design,
      // they come from join on users table when reading.
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? replyCount,
    int? likeCount,
    String? userDisplayName,
    String? userAvatarUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
    );
  }

  //</editor-fold>
}