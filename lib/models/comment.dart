class Comment {
  final String id;
  final String targetType; // 'post', 'reel', 'story'
  final String targetId;
  final String userId;
  final String? parentId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int replyCount;
  final int likeCount;
  final String? userDisplayName;
  final String? userAvatarUrl;

  const Comment({
    required this.id,
    required this.targetType,
    required this.targetId,
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

  factory Comment.fromMap(Map<String, dynamic> map) {
    final userMap = map['profiles'] as Map<String, dynamic>?;
    return Comment(
      id: map['id'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      userId: map['user_id'] as String,
      parentId: map['parent_id'] as String?,
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      replyCount: map['reply_count'] is int
          ? map['reply_count'] as int
          : int.tryParse('${map['reply_count'] ?? 0}') ?? 0,
      likeCount: map['like_count'] is int
          ? map['like_count'] as int
          : int.tryParse('${map['like_count'] ?? 0}') ?? 0,
      userDisplayName: userMap?['display_name'] ??
          userMap?['full_name'] ??
          userMap?['name'],
      userAvatarUrl:
      userMap?['avatar_url'] ?? userMap?['avatar'] ?? userMap?['photo_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_type': targetType,
      'target_id': targetId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reply_count': replyCount,
      'like_count': likeCount,
    };
  }

  Comment copyWith({
    String? id,
    String? targetType,
    String? targetId,
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
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
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
}
