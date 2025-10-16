part of 'home_bloc.dart';

class HomeState {
  final LoadStatus loadStoryStatus;
  final LoadStatus loadPostStatus;
  final List<Story> userStories;
  final Map<String, List<Story>> currentStory;
  final List<Profile> suggestionProfile;
  final String errorMessage;

  const HomeState.init({
    this.loadStoryStatus = LoadStatus.init,
    this.loadPostStatus = LoadStatus.init,
    this.userStories = const [],
    this.currentStory = const {},
    this.suggestionProfile = const [],
    this.errorMessage = '',
  });

  //<editor-fold desc="Data Methods">
  const HomeState({
    required this.loadStoryStatus,
    required this.loadPostStatus,
    required this.userStories,
    required this.currentStory,
    required this.suggestionProfile,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeState &&
          runtimeType == other.runtimeType &&
          loadStoryStatus == other.loadStoryStatus &&
          loadPostStatus == other.loadPostStatus &&
          userStories == other.userStories &&
          currentStory == other.currentStory &&
          suggestionProfile == other.suggestionProfile &&
          errorMessage == other.errorMessage);

  @override
  int get hashCode =>
      loadStoryStatus.hashCode ^ loadPostStatus.hashCode ^ userStories.hashCode ^ currentStory.hashCode ^ suggestionProfile.hashCode ^ errorMessage.hashCode;

  @override
  String toString() {
    return 'HomeState{' +
        ' loadStoryStatus: $loadStoryStatus,' +
        ' loadPostStatus: $loadPostStatus,' +
        ' userStories: $userStories,' +
        ' currentStory: $currentStory,' +
        ' suggestionProfile: $suggestionProfile,' +
        ' errorMessage: $errorMessage,' +
        '}';
  }

  HomeState copyWith({
    LoadStatus? loadStoryStatus,
    LoadStatus? loadPostStatus,
    List<Story>? userStories,
    Map<String, List<Story>>? currentStory,
    List<Profile>? suggestionProfile,
    String? errorMessage,
  }) {
    return HomeState(
      loadStoryStatus: loadStoryStatus ?? this.loadStoryStatus,
      loadPostStatus: loadPostStatus ?? this.loadPostStatus,
      userStories: userStories ?? this.userStories,
      currentStory: currentStory ?? this.currentStory,
      suggestionProfile: suggestionProfile ?? this.suggestionProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStoryStatus': this.loadStoryStatus,
      'loadPostStatus': this.loadPostStatus,
      'userStories': this.userStories,
      'currentStory': this.currentStory,
      'suggestionProfile': this.suggestionProfile,
      'errorMessage': this.errorMessage,
    };
  }

  factory HomeState.fromMap(Map<String, dynamic> map) {
    return HomeState(
      loadStoryStatus: map['loadStoryStatus'] as LoadStatus,
      loadPostStatus: map['loadPostStatus'] as LoadStatus,
      userStories: map['userStories'] as List<Story>,
      currentStory: map['currentStory'] as Map<String, List<Story>>,
      suggestionProfile: map['suggestionProfile'] as List<Profile>,
      errorMessage: map['errorMessage'] as String,
    );
  }

  //</editor-fold>
}
