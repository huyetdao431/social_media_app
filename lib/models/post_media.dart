class PostMedia {
  final String id;
  final String postId;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int orderIndex;
  final bool isPrimary;
  final String? mimeType;
  final int? fileSize;
  final double? duration;
  final String? thumbUrl;

  //<editor-fold desc="Data Methods">
  const PostMedia({
    required this.id,
    required this.postId,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    this.updatedAt,
    required this.orderIndex,
    required this.isPrimary,
    this.mimeType,
    this.fileSize,
    this.duration,
    this.thumbUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostMedia &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          mediaUrl == other.mediaUrl &&
          mediaType == other.mediaType &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          orderIndex == other.orderIndex &&
          isPrimary == other.isPrimary &&
          mimeType == other.mimeType &&
          fileSize == other.fileSize &&
          duration == other.duration &&
          thumbUrl == other.thumbUrl);

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      mediaUrl.hashCode ^
      mediaType.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      orderIndex.hashCode ^
      isPrimary.hashCode ^
      mimeType.hashCode ^
      fileSize.hashCode ^
      duration.hashCode ^
      thumbUrl.hashCode;

  @override
  String toString() {
    return 'PostMedia{' +
        ' id: $id,' +
        ' postId: $postId,' +
        ' mediaUrl: $mediaUrl,' +
        ' mediaType: $mediaType,' +
        ' createdAt: $createdAt,' +
        ' updatedAt: $updatedAt,' +
        ' orderIndex: $orderIndex,' +
        ' isPrimary: $isPrimary,' +
        ' mimeType: $mimeType,' +
        ' fileSize: $fileSize,' +
        ' duration: $duration,' +
        ' thumbUrl: $thumbUrl,' +
        '}';
  }

  PostMedia copyWith({
    String? id,
    String? postId,
    String? mediaUrl,
    String? mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? orderIndex,
    bool? isPrimary,
    String? mimeType,
    int? fileSize,
    double? duration,
    String? thumbUrl,
  }) {
    return PostMedia(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      isPrimary: isPrimary ?? this.isPrimary,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      thumbUrl: thumbUrl ?? this.thumbUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'postId': this.postId,
      'mediaUrl': this.mediaUrl,
      'mediaType': this.mediaType,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'orderIndex': this.orderIndex,
      'isPrimary': this.isPrimary,
      'mimeType': this.mimeType,
      'fileSize': this.fileSize,
      'duration': this.duration,
      'thumbUrl': this.thumbUrl,
    };
  }

  factory PostMedia.fromMap(Map<String, dynamic> map) {
    return PostMedia(
      id: map['id'] as String,
      postId: map['postId'] as String,
      mediaUrl: map['mediaUrl'] as String,
      mediaType: map['mediaType'] as String,
      createdAt: map['createdAt'] as DateTime,
      updatedAt: map['updatedAt'] as DateTime,
      orderIndex: map['orderIndex'] as int,
      isPrimary: map['isPrimary'] as bool,
      mimeType: map['mimeType'] as String,
      fileSize: map['fileSize'] as int,
      duration: map['duration'] as double,
      thumbUrl: map['thumbUrl'] as String,
    );
  }

  //</editor-fold>
}