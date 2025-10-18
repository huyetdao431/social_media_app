class Reel {
  final String reelId;
  final String userId;
  final String caption;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int duration;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final String posterUrl;
  final String mediaUrl;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final String? userName;
  final String? avatarUrl;

  const Reel({
    required this.reelId,
    required this.userId,
    required this.caption,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
    required this.duration,
    this.width,
    this.height,
    this.aspectRatio,
    required this.posterUrl,
    required this.mediaUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    this.userName,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Reel &&
              runtimeType == other.runtimeType &&
              reelId == other.reelId &&
              userId == other.userId &&
              caption == other.caption &&
              isPublic == other.isPublic &&
              createdAt == other.createdAt &&
              updatedAt == other.updatedAt &&
              duration == other.duration &&
              width == other.width &&
              height == other.height &&
              aspectRatio == other.aspectRatio &&
              posterUrl == other.posterUrl &&
              mediaUrl == other.mediaUrl &&
              viewCount == other.viewCount &&
              likeCount == other.likeCount &&
              commentCount == other.commentCount &&
              userName == other.userName &&
              avatarUrl == other.avatarUrl);

  @override
  int get hashCode =>
      reelId.hashCode ^
      userId.hashCode ^
      caption.hashCode ^
      isPublic.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      duration.hashCode ^
      width.hashCode ^
      height.hashCode ^
      aspectRatio.hashCode ^
      posterUrl.hashCode ^
      mediaUrl.hashCode ^
      viewCount.hashCode ^
      likeCount.hashCode ^
      commentCount.hashCode ^
      (userName?.hashCode ?? 0) ^
      (avatarUrl?.hashCode ?? 0);

  @override
  String toString() {
    return 'Reel{ reelId: $reelId, userId: $userId, caption: $caption, isPublic: $isPublic, '
        'createdAt: $createdAt, updatedAt: $updatedAt, duration: $duration, width: $width, height: $height, '
        'aspectRatio: $aspectRatio, posterUrl: $posterUrl, mediaUrl: $mediaUrl, viewCount: $viewCount, '
        'likeCount: $likeCount, commentCount: $commentCount, userName: $userName, avatarUrl: $avatarUrl }';
  }

  Reel copyWith({
    String? reelId,
    String? userId,
    String? caption,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? duration,
    double? width,
    double? height,
    double? aspectRatio,
    String? posterUrl,
    String? mediaUrl,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    String? userName,
    String? avatarUrl,
  }) {
    return Reel(
      reelId: reelId ?? this.reelId,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      posterUrl: posterUrl ?? this.posterUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': reelId,
      'user_id': userId,
      'caption': caption,
      'is_public': isPublic,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'duration': duration,
      'width': width,
      'height': height,
      'aspect_ratio': aspectRatio,
      'poster_url': posterUrl,
      'media_url': mediaUrl,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'profiles': {
        'username': userName,
        'avatar_url': avatarUrl,
      }
    };
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory Reel.fromMap(Map<String, dynamic> map) {
    final profiles = (map['profiles'] is Map) ? Map<String, dynamic>.from(map['profiles'] as Map) : null;

    return Reel(
      reelId: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      caption: map['caption']?.toString() ?? '',
      isPublic: map['is_public'] == null ? true : (map['is_public'] is bool ? map['is_public'] as bool : (map['is_public'].toString() == 't' || map['is_public'].toString() == 'true')),
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
      duration: _toInt(map['duration']),
      width: _toDouble(map['width']),
      height: _toDouble(map['height']),
      aspectRatio: _toDouble(map['aspect_ratio']),
      posterUrl: map['poster_url']?.toString() ?? '',
      mediaUrl: map['media_url']?.toString() ?? '',
      viewCount: _toInt(map['view_count']),
      likeCount: _toInt(map['like_count']),
      commentCount: _toInt(map['comment_count']),
      userName: profiles != null ? (profiles['username']?.toString()) : (map['username']?.toString()),
      avatarUrl: profiles != null ? (profiles['avatar_url']?.toString()) : (map['avatar_url']?.toString()),
    );
  }
}