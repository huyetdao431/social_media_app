part of 'story_bloc.dart';

class StoryState {
  final File? storyMedia;
  final String mediaType;
  final LoadStatus loadStatus;
  final String errorMessage;
  final Story? currentStory;

  const StoryState.init({
    this.storyMedia,
    this.mediaType = '',
    this.loadStatus = LoadStatus.init,
    this.errorMessage = '',
    this.currentStory,
  });

//<editor-fold desc="Data Methods">


  const StoryState({
    this.storyMedia,
    required this.mediaType,
    required this.loadStatus,
    required this.errorMessage,
    this.currentStory,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is StoryState &&
              runtimeType == other.runtimeType &&
              storyMedia == other.storyMedia &&
              mediaType == other.mediaType &&
              loadStatus == other.loadStatus &&
              errorMessage == other.errorMessage &&
              currentStory == other.currentStory
          );


  @override
  int get hashCode =>
      storyMedia.hashCode ^
      mediaType.hashCode ^
      loadStatus.hashCode ^
      errorMessage.hashCode ^
      currentStory.hashCode;


  @override
  String toString() {
    return 'StoryState{' +
        ' storyMedia: $storyMedia,' +
        ' mediaType: $mediaType,' +
        ' loadStatus: $loadStatus,' +
        ' errorMessage: $errorMessage,' +
        ' currentStory: $currentStory,' +
        '}';
  }


  StoryState copyWith({
    File? storyMedia,
    String? mediaType,
    LoadStatus? loadStatus,
    String? errorMessage,
    Story? currentStory,
  }) {
    return StoryState(
      storyMedia: storyMedia ?? this.storyMedia,
      mediaType: mediaType ?? this.mediaType,
      loadStatus: loadStatus ?? this.loadStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStory: currentStory ?? this.currentStory,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'storyMedia': this.storyMedia,
      'mediaType': this.mediaType,
      'loadStatus': this.loadStatus,
      'errorMessage': this.errorMessage,
      'currentStory': this.currentStory,
    };
  }

  factory StoryState.fromMap(Map<String, dynamic> map) {
    return StoryState(
      storyMedia: map['storyMedia'] as File,
      mediaType: map['mediaType'] as String,
      loadStatus: map['loadStatus'] as LoadStatus,
      errorMessage: map['errorMessage'] as String,
      currentStory: map['currentStory'] as Story,
    );
  }


//</editor-fold>
}
