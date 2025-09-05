part of 'story_cubit.dart';

class StoryState {
  final File? storyMedia;
  final AssetEntity? selectedMedia;
  final LoadStatus loadStatus;

  const StoryState.init({
    this.storyMedia,
    this.selectedMedia,
    this.loadStatus = LoadStatus.init,
  });

//<editor-fold desc="Data Methods">


  const StoryState({
    this.storyMedia,
    this.selectedMedia,
    required this.loadStatus,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is StoryState &&
              runtimeType == other.runtimeType &&
              storyMedia == other.storyMedia &&
              selectedMedia == other.selectedMedia &&
              loadStatus == other.loadStatus
          );


  @override
  int get hashCode =>
      storyMedia.hashCode ^
      selectedMedia.hashCode ^
      loadStatus.hashCode;


  @override
  String toString() {
    return 'StoryState{' +
        ' storyMedia: $storyMedia,' +
        ' selectedMedia: $selectedMedia,' +
        ' loadStatus: $loadStatus,' +
        '}';
  }


  StoryState copyWith({
    File? storyMedia,
    AssetEntity? selectedMedia,
    LoadStatus? loadStatus,
  }) {
    return StoryState(
      storyMedia: storyMedia ?? this.storyMedia,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'storyMedia': this.storyMedia,
      'selectedMedia': this.selectedMedia,
      'loadStatus': this.loadStatus,
    };
  }

  factory StoryState.fromMap(Map<String, dynamic> map) {
    return StoryState(
      storyMedia: map['storyMedia'] as File,
      selectedMedia: map['selectedMedia'] as AssetEntity,
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }


//</editor-fold>
}
