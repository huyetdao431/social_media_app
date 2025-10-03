part of 'story_cubit.dart';

class StoryState {
  final File? storyMedia;
  final String mediaType;
  final LoadStatus loadStatus;

  const StoryState.init({
    this.storyMedia,
    this.mediaType = '',
    this.loadStatus = LoadStatus.init,
  });

//<editor-fold desc="Data Methods">


  const StoryState({
    this.storyMedia,
    required this.mediaType,
    required this.loadStatus,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is StoryState &&
              runtimeType == other.runtimeType &&
              storyMedia == other.storyMedia &&
              mediaType == other.mediaType &&
              loadStatus == other.loadStatus
          );


  @override
  int get hashCode =>
      storyMedia.hashCode ^
      mediaType.hashCode ^
      loadStatus.hashCode;


  @override
  String toString() {
    return 'StoryState{' +
        ' storyMedia: $storyMedia,' +
        ' mediaType: $mediaType,' +
        ' loadStatus: $loadStatus,' +
        '}';
  }


  StoryState copyWith({
    File? storyMedia,
    String? mediaType,
    LoadStatus? loadStatus,
  }) {
    return StoryState(
      storyMedia: storyMedia ?? this.storyMedia,
      mediaType: mediaType ?? this.mediaType,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'storyMedia': this.storyMedia,
      'mediaType': this.mediaType,
      'loadStatus': this.loadStatus,
    };
  }

  factory StoryState.fromMap(Map<String, dynamic> map) {
    return StoryState(
      storyMedia: map['storyMedia'] as File,
      mediaType: map['mediaType'] as String,
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }


//</editor-fold>
}
