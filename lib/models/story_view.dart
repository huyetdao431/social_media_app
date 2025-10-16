class StoryView{
  final String id;
  final String storyId;
  final String viewerId;
  final DateTime? viewedAt;
  final String? deviceInfo;

  //<editor-fold desc="Data Methods">
  const StoryView({
    required this.id,
    required this.storyId,
    required this.viewerId,
    this.viewedAt,
    this.deviceInfo,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is StoryView &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              storyId == other.storyId &&
              viewerId == other.viewerId &&
              viewedAt == other.viewedAt &&
              deviceInfo == other.deviceInfo
          );


  @override
  int get hashCode =>
      id.hashCode ^
      storyId.hashCode ^
      viewerId.hashCode ^
      viewedAt.hashCode ^
      deviceInfo.hashCode;


  @override
  String toString() {
    return 'StoryView{' +
        ' id: $id,' +
        ' storyId: $storyId,' +
        ' viewerId: $viewerId,' +
        ' viewedAt: $viewedAt,' +
        ' deviceInfo: $deviceInfo,' +
        '}';
  }


  StoryView copyWith({
    String? id,
    String? storyId,
    String? viewerId,
    DateTime? viewedAt,
    String? deviceInfo,
  }) {
    return StoryView(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      viewerId: viewerId ?? this.viewerId,
      viewedAt: viewedAt ?? this.viewedAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }


  factory StoryView.fromMap(Map<String, dynamic> map) {
    return StoryView(
      id: map['id'] as String,
      storyId: map['story_id'] as String,
      viewerId: map['viewer_id'] as String,
      viewedAt: map['viewed_at'] != null ? DateTime.parse(map['viewed_at']) : null,
      deviceInfo: map['device_info'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'story_id': storyId,
      'viewer_id': viewerId,
      'viewed_at': viewedAt?.toIso8601String(),
      'device_info': deviceInfo,
    };
  }


//</editor-fold>
}