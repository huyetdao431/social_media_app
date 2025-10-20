class Story {
  final String id;
  final String userId;
  final String? mediaUrl;
  final String? mediaType;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final String? mimeType;
  final double? duration;
  final String? thumbUrl;
  final String? visibility;
  final bool? isActive;
  final DateTime? updatedAt;
  final int? viewCount;
  final bool isViewed;
  final String? username;
  final String? avatarUrl;

  //<editor-fold desc="Data Methods">
  const Story({
    required this.id,
    required this.userId,
    this.mediaUrl,
    this.mediaType,
    this.expiresAt,
    this.createdAt,
    this.mimeType,
    this.duration,
    this.thumbUrl,
    this.visibility,
    this.isActive,
    this.updatedAt,
    this.viewCount,
    this.username,
    this.avatarUrl,
    this.isViewed = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Story &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          mediaUrl == other.mediaUrl &&
          mediaType == other.mediaType &&
          expiresAt == other.expiresAt &&
          createdAt == other.createdAt &&
          mimeType == other.mimeType &&
          duration == other.duration &&
          thumbUrl == other.thumbUrl &&
          visibility == other.visibility &&
          isActive == other.isActive &&
          updatedAt == other.updatedAt &&
          viewCount == other.viewCount);

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      mediaUrl.hashCode ^
      mediaType.hashCode ^
      expiresAt.hashCode ^
      createdAt.hashCode ^
      mimeType.hashCode ^
      duration.hashCode ^
      thumbUrl.hashCode ^
      visibility.hashCode ^
      isActive.hashCode ^
      updatedAt.hashCode ^
      viewCount.hashCode;

  @override
  String toString() {
    return 'Story{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' mediaUrl: $mediaUrl,' +
        ' mediaType: $mediaType,' +
        ' expiresAt: $expiresAt,' +
        ' createdAt: $createdAt,' +
        ' mimeType: $mimeType,' +
        ' duration: $duration,' +
        ' thumbUrl: $thumbUrl,' +
        ' visibility: $visibility,' +
        ' isActive: $isActive,' +
        ' updatedAt: $updatedAt,' +
        ' viewCount: $viewCount,' +
        '}';
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      userId: map['user_id'],
      mediaUrl: map['media_url'],
      mediaType: map['media_type'],
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      mimeType: map['mime_type'],
      duration: (map['duration'] as num?)?.toDouble(),
      thumbUrl: map['thumb_url'],
      visibility: map['visibility'],
      isActive: map['is_active'],
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      viewCount: map['view_count'] is int ? map['view_count'] : int.tryParse('${map['view_count']}'),
      username: map['username'],
      avatarUrl: map['avatar_url'],
      isViewed: map['is_viewed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'mime_type': mimeType,
      'duration': duration,
      'thumb_url': thumbUrl,
      'visibility': visibility,
      'is_active': isActive,
      'updated_at': updatedAt?.toIso8601String(),
      'view_count': viewCount,
      'profiles': {
        'username': username,
        'avatar_url': avatarUrl,
      },
    };
  }

  Story copyWith({
    bool? isViewed,
  }) {
    return Story(
      id: id,
      userId: userId,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      expiresAt: expiresAt,
      createdAt: createdAt,
      mimeType: mimeType,
      duration: duration,
      thumbUrl: thumbUrl,
      visibility: visibility,
      isActive: isActive,
      updatedAt: updatedAt,
      viewCount: viewCount,
      username: username,
      avatarUrl: avatarUrl,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  //</editor-fold>
}