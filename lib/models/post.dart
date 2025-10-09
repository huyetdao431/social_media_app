import 'package:social_media_app/models/post_media.dart';

class Post {
  final String id;
  final String userId;
  final String? caption;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final List<PostMedia>? mediaList;
  final double aspectRatio;
  final String status;

  //<editor-fold desc="Data Methods">
  const Post({
    required this.id,
    required this.userId,
    this.caption,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    this.mediaList,
    required this.aspectRatio,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          caption == other.caption &&
          createdAt == other.createdAt &&
          likesCount == other.likesCount &&
          commentsCount == other.commentsCount &&
          mediaList == other.mediaList &&
          aspectRatio == other.aspectRatio &&
          status == other.status);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      caption.hashCode ^
      createdAt.hashCode ^
      likesCount.hashCode ^
      commentsCount.hashCode ^
      mediaList.hashCode ^
      aspectRatio.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'Post{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' caption: $caption,' +
        ' createdAt: $createdAt,' +
        ' likesCount: $likesCount,' +
        ' commentsCount: $commentsCount,' +
        ' mediaList: $mediaList,' +
        ' aspectRatio: $aspectRatio,' +
        ' status: $status,' +
        '}';
  }

  Post copyWith({
    String? id,
    String? userId,
    String? caption,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    List<PostMedia>? mediaList,
    double? aspectRatio,
    String? status,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      mediaList: mediaList ?? this.mediaList,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'aspect_ratio': aspectRatio,
      'status': status,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    final mediaList = map['media_list'];

    return Post(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      caption: map['caption'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      likesCount: map['likes_count'] ?? 0,
      commentsCount: map['comments_count'] ?? 0,
      mediaList: mediaList is List<PostMedia>
          ? mediaList
          : (mediaList as List?)?.map((m) => PostMedia.fromMap(m)).toList(),
      aspectRatio: (map['aspect_ratio'] as num?)?.toDouble() ?? 1.0,
      status: map['status'] ?? 'active',
    );
  }
  //</editor-fold>
}