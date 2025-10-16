class HighlightItem {
  final String id;
  final String highlightId;
  final String storyId;
  final int? orderIndex;

  //<editor-fold desc="Data Methods">
  const HighlightItem({
    required this.id,
    required this.highlightId,
    required this.storyId,
    this.orderIndex,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is HighlightItem &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              highlightId == other.highlightId &&
              storyId == other.storyId &&
              orderIndex == other.orderIndex
          );


  @override
  int get hashCode =>
      id.hashCode ^
      highlightId.hashCode ^
      storyId.hashCode ^
      orderIndex.hashCode;


  @override
  String toString() {
    return 'HighlightItem{' +
        ' id: $id,' +
        ' highlightId: $highlightId,' +
        ' storyId: $storyId,' +
        ' orderIndex: $orderIndex,' +
        '}';
  }


  HighlightItem copyWith({
    String? id,
    String? highlightId,
    String? storyId,
    int? orderIndex,
  }) {
    return HighlightItem(
      id: id ?? this.id,
      highlightId: highlightId ?? this.highlightId,
      storyId: storyId ?? this.storyId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }


  factory HighlightItem.fromMap(Map<String, dynamic> map) {
    return HighlightItem(
      id: map['id'] as String,
      highlightId: map['highlight_id'] as String,
      storyId: map['story_id'] as String,
      orderIndex: map['order_index'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'highlight_id': highlightId,
      'story_id': storyId,
      'order_index': orderIndex,
    };
  }


//</editor-fold>
}