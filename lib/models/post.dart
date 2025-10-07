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
      'id': this.id,
      'userId': this.userId,
      'caption': this.caption,
      'createdAt': this.createdAt,
      'likesCount': this.likesCount,
      'commentsCount': this.commentsCount,
      'mediaList': this.mediaList,
      'aspectRatio': this.aspectRatio,
      'status': this.status,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      userId: map['userId'] as String,
      caption: map['caption'] as String,
      createdAt: map['createdAt'] as DateTime,
      likesCount: map['likesCount'] as int,
      commentsCount: map['commentsCount'] as int,
      mediaList: map['mediaList'] as List<PostMedia>,
      aspectRatio: map['aspectRatio'] as double,
      status: map['status'] as String,
    );
  }

  //</editor-fold>
}