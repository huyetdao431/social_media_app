part of 'post_cubit.dart';

class PostState {
  final LoadStatus loadStatus;
  final List<AssetEntity> selectedAssets;
  final List<Map<String, dynamic>> assets;
  final List<int> editedAssetIndex;
  final double aspectRatio;
  final int selectedIndex;
  final String postId;
  final String errorMessage;

  const PostState.init({
    this.loadStatus = LoadStatus.init,
    this.selectedAssets = const [],
    this.assets = const [],
    this.editedAssetIndex = const [],
    this.aspectRatio = 1,
    this.selectedIndex = 0,
    this.postId = '',
    this.errorMessage = ''
  });

//<editor-fold desc="Data Methods">


  const PostState({
    required this.loadStatus,
    required this.selectedAssets,
    required this.assets,
    required this.editedAssetIndex,
    required this.aspectRatio,
    required this.selectedIndex,
    required this.postId,
    required this.errorMessage,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is PostState &&
              runtimeType == other.runtimeType &&
              loadStatus == other.loadStatus &&
              selectedAssets == other.selectedAssets &&
              assets == other.assets &&
              editedAssetIndex == other.editedAssetIndex &&
              aspectRatio == other.aspectRatio &&
              selectedIndex == other.selectedIndex &&
              postId == other.postId &&
              errorMessage == other.errorMessage
          );


  @override
  int get hashCode =>
      loadStatus.hashCode ^
      selectedAssets.hashCode ^
      assets.hashCode ^
      editedAssetIndex.hashCode ^
      aspectRatio.hashCode ^
      selectedIndex.hashCode ^
      postId.hashCode ^
      errorMessage.hashCode;


  @override
  String toString() {
    return 'PostState{' +
        ' loadStatus: $loadStatus,' +
        ' selectedAssets: $selectedAssets,' +
        ' assets: $assets,' +
        ' editedAssetIndex: $editedAssetIndex,' +
        ' aspectRatio: $aspectRatio,' +
        ' selectedIndex: $selectedIndex,' +
        ' postId: $postId,' +
        ' errorMessage: $errorMessage,' +
        '}';
  }


  PostState copyWith({
    LoadStatus? loadStatus,
    List<AssetEntity>? selectedAssets,
    List<Map<String, dynamic>>? assets,
    List<int>? editedAssetIndex,
    double? aspectRatio,
    int? selectedIndex,
    String? postId,
    String? errorMessage,
  }) {
    return PostState(
      loadStatus: loadStatus ?? this.loadStatus,
      selectedAssets: selectedAssets ?? this.selectedAssets,
      assets: assets ?? this.assets,
      editedAssetIndex: editedAssetIndex ?? this.editedAssetIndex,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      postId: postId ?? this.postId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'selectedAssets': this.selectedAssets,
      'assets': this.assets,
      'editedAssetIndex': this.editedAssetIndex,
      'aspectRatio': this.aspectRatio,
      'selectedIndex': this.selectedIndex,
      'postId': this.postId,
      'errorMessage': this.errorMessage,
    };
  }

  factory PostState.fromMap(Map<String, dynamic> map) {
    return PostState(
      loadStatus: map['loadStatus'] as LoadStatus,
      selectedAssets: map['selectedAssets'] as List<AssetEntity>,
      assets: map['assets'] as List<Map<String, dynamic>>,
      editedAssetIndex: map['editedAssetIndex'] as List<int>,
      aspectRatio: map['aspectRatio'] as double,
      selectedIndex: map['selectedIndex'] as int,
      postId: map['postId'] as String,
      errorMessage: map['errorMessage'] as String,
    );
  }


//</editor-fold>
}
