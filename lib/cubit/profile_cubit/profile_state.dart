part of 'profile_cubit.dart';

class ProfileState {
  final LoadStatus loadStatus;
  final LoadStatus loadPostStatus;
  final Profile? userProfile;
  final List<Post> userPosts;
  final String errorMessage;
  final bool hasMorePosts;
  final int mediaIndex;

  const ProfileState.init({
    this.loadStatus = LoadStatus.init,
    this.loadPostStatus = LoadStatus.init,
    this.userProfile,
    this.userPosts = const [],
    this.errorMessage = '',
    this.hasMorePosts = true,
    this.mediaIndex = 0,
  });

  //<editor-fold desc="Data Methods">
  const ProfileState({
    required this.loadStatus,
    required this.loadPostStatus,
    this.userProfile,
    required this.userPosts,
    required this.errorMessage,
    required this.hasMorePosts,
    required this.mediaIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          loadPostStatus == other.loadPostStatus &&
          userProfile == other.userProfile &&
          userPosts == other.userPosts &&
          errorMessage == other.errorMessage &&
          hasMorePosts == other.hasMorePosts &&
          mediaIndex == other.mediaIndex);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      loadPostStatus.hashCode ^
      userProfile.hashCode ^
      userPosts.hashCode ^
      errorMessage.hashCode ^
      hasMorePosts.hashCode ^
      mediaIndex.hashCode;

  @override
  String toString() {
    return 'ProfileState{' +
        ' loadStatus: $loadStatus,' +
        ' loadPostStatus: $loadPostStatus,' +
        ' userProfile: $userProfile,' +
        ' userPosts: $userPosts,' +
        ' errorMessage: $errorMessage,' +
        ' hasMorePosts: $hasMorePosts,' +
        ' mediaIndex: $mediaIndex,' +
        '}';
  }

  ProfileState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? loadPostStatus,
    Profile? userProfile,
    List<Post>? userPosts,
    String? errorMessage,
    bool? hasMorePosts,
    int? mediaIndex,
  }) {
    return ProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadPostStatus: loadPostStatus ?? this.loadPostStatus,
      userProfile: userProfile ?? this.userProfile,
      userPosts: userPosts ?? this.userPosts,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      mediaIndex: mediaIndex ?? this.mediaIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'loadPostStatus': this.loadPostStatus,
      'userProfile': this.userProfile,
      'userPosts': this.userPosts,
      'errorMessage': this.errorMessage,
      'hasMorePosts': this.hasMorePosts,
      'mediaIndex': this.mediaIndex,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      loadStatus: map['loadStatus'] as LoadStatus,
      loadPostStatus: map['loadPostStatus'] as LoadStatus,
      userProfile: map['userProfile'] as Profile,
      userPosts: map['userPosts'] as List<Post>,
      errorMessage: map['errorMessage'] as String,
      hasMorePosts: map['hasMorePosts'] as bool,
      mediaIndex: map['mediaIndex'] as int,
    );
  }

  //</editor-fold>
}
