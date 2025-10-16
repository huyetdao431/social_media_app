class StoryHighlight {
  final String id;
  final String userId;
  final String? title;
  final String? coverStoryId;
  final DateTime? createdAt;

  //<editor-fold desc="Data Methods">
  const StoryHighlight({
    required this.id,
    required this.userId,
    this.title,
    this.coverStoryId,
    this.createdAt,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is StoryHighlight &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              userId == other.userId &&
              title == other.title &&
              coverStoryId == other.coverStoryId &&
              createdAt == other.createdAt
          );


  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      coverStoryId.hashCode ^
      createdAt.hashCode;


  @override
  String toString() {
    return 'StoryHighlight{' +
        ' id: $id,' +
        ' userId: $userId,' +
        ' title: $title,' +
        ' coverStoryId: $coverStoryId,' +
        ' createdAt: $createdAt,' +
        '}';
  }


  StoryHighlight copyWith({
    String? id,
    String? userId,
    String? title,
    String? coverStoryId,
    DateTime? createdAt,
  }) {
    return StoryHighlight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      coverStoryId: coverStoryId ?? this.coverStoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }


  factory StoryHighlight.fromMap(Map<String, dynamic> map) {
    return StoryHighlight(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String?,
      coverStoryId: map['cover_story_id'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'cover_story_id': coverStoryId,
      'created_at': createdAt?.toIso8601String(),
    };
  }


//</editor-fold>
}