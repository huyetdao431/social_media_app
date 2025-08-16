part of 'post_cubit.dart';

class PostState {
  final LoadStatus loadStatus;
  final List<Uint8List> selectedAssets;
  final double aspectRatio;
  final int seletedIndex;

  const PostState.init({
    this.loadStatus = LoadStatus.init,
    this.selectedAssets = const [],
    this.aspectRatio = 1,
    this.seletedIndex = 0,
  });

  //<editor-fold desc="Data Methods">
  const PostState({
    required this.loadStatus,
    required this.selectedAssets,
    required this.aspectRatio,
    required this.seletedIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          selectedAssets == other.selectedAssets &&
          aspectRatio == other.aspectRatio &&
          seletedIndex == other.seletedIndex);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      selectedAssets.hashCode ^
      aspectRatio.hashCode ^
      seletedIndex.hashCode;

  @override
  String toString() {
    return 'PostState{' +
        ' loadStatus: $loadStatus,' +
        ' selectedAssets: $selectedAssets,' +
        ' aspectRatio: $aspectRatio,' +
        ' seletedIndex: $seletedIndex,' +
        '}';
  }

  PostState copyWith({
    LoadStatus? loadStatus,
    List<Uint8List>? selectedAssets,
    double? aspectRatio,
    int? seletedIndex,
  }) {
    return PostState(
      loadStatus: loadStatus ?? this.loadStatus,
      selectedAssets: selectedAssets ?? this.selectedAssets,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      seletedIndex: seletedIndex ?? this.seletedIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'selectedAssets': this.selectedAssets,
      'aspectRatio': this.aspectRatio,
      'seletedIndex': this.seletedIndex,
    };
  }

  factory PostState.fromMap(Map<String, dynamic> map) {
    return PostState(
      loadStatus: map['loadStatus'] as LoadStatus,
      selectedAssets: map['selectedAssets'] as List<Uint8List>,
      aspectRatio: map['aspectRatio'] as double,
      seletedIndex: map['seletedIndex'] as int,
    );
  }

  //</editor-fold>
}
