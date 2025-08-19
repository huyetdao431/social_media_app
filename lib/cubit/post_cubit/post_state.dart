part of 'post_cubit.dart';

class PostState {
  final LoadStatus loadStatus;
  final List<AssetEntity> selectedAssets;
  final List<Uint8List> thumbnails;
  final double aspectRatio;
  final int selectedIndex;

  const PostState.init({
    this.loadStatus = LoadStatus.init,
    this.selectedAssets = const [],
    this.thumbnails = const [],
    this.aspectRatio = 1,
    this.selectedIndex = 0,
  });

  //<editor-fold desc="Data Methods">
  const PostState({
    required this.loadStatus,
    required this.selectedAssets,
    required this.thumbnails,
    required this.aspectRatio,
    required this.selectedIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          selectedAssets == other.selectedAssets &&
          thumbnails == other.thumbnails &&
          aspectRatio == other.aspectRatio &&
          selectedIndex == other.selectedIndex);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      selectedAssets.hashCode ^
      thumbnails.hashCode ^
      aspectRatio.hashCode ^
      selectedIndex.hashCode;

  @override
  String toString() {
    return 'PostState{' +
        ' loadStatus: $loadStatus,' +
        ' selectedAssets: $selectedAssets,' +
        ' thumbnails: $thumbnails,' +
        ' aspectRatio: $aspectRatio,' +
        ' selectedIndex: $selectedIndex,' +
        '}';
  }

  PostState copyWith({
    LoadStatus? loadStatus,
    List<AssetEntity>? selectedAssets,
    List<Uint8List>? thumbnails,
    double? aspectRatio,
    int? selectedIndex,
  }) {
    return PostState(
      loadStatus: loadStatus ?? this.loadStatus,
      selectedAssets: selectedAssets ?? this.selectedAssets,
      thumbnails: thumbnails ?? this.thumbnails,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'selectedAssets': this.selectedAssets,
      'thumbnails': this.thumbnails,
      'aspectRatio': this.aspectRatio,
      'selectedIndex': this.selectedIndex,
    };
  }

  factory PostState.fromMap(Map<String, dynamic> map) {
    return PostState(
      loadStatus: map['loadStatus'] as LoadStatus,
      selectedAssets: map['selectedAssets'] as List<AssetEntity>,
      thumbnails: map['thumbnails'] as List<Uint8List>,
      aspectRatio: map['aspectRatio'] as double,
      selectedIndex: map['selectedIndex'] as int,
    );
  }

  //</editor-fold>
}
