part of 'profile_cubit.dart';

class ProfileState {
  final LoadStatus loadStatus;
  final LoadStatus loadPostStatus;
  final LoadStatus loadReelStatus;
  final Profile? userProfile;
  final List<Post> userPosts;
  final List<Reel> userReels;
  final String errorMessage;
  final bool hasMorePosts;
  final bool hasMoreReels;
  final int mediaIndex;

  const ProfileState.init({
    this.loadStatus = LoadStatus.init,
    this.loadPostStatus = LoadStatus.init,
    this.loadReelStatus = LoadStatus.init,
    this.userProfile,
    this.userPosts = const [],
    this.userReels = const [],
    this.errorMessage = '',
    this.hasMorePosts = true,
    this.hasMoreReels = true,
    this.mediaIndex = 0,
  });

  //<editor-fold desc="Data Methods">
  const ProfileState({
    required this.loadStatus,
    required this.loadPostStatus,
    required this.loadReelStatus,
    this.userProfile,
    required this.userPosts,
    required this.userReels,
    required this.errorMessage,
    required this.hasMorePosts,
    required this.hasMoreReels,
    required this.mediaIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          loadPostStatus == other.loadPostStatus &&
          loadReelStatus == other.loadReelStatus &&
          userProfile == other.userProfile &&
          userPosts == other.userPosts &&
          userReels == other.userReels &&
          errorMessage == other.errorMessage &&
          hasMorePosts == other.hasMorePosts &&
          hasMoreReels == other.hasMoreReels &&
          mediaIndex == other.mediaIndex);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      loadPostStatus.hashCode ^
      loadReelStatus.hashCode ^
      userProfile.hashCode ^
      userPosts.hashCode ^
      userReels.hashCode ^
      errorMessage.hashCode ^
      hasMorePosts.hashCode ^
      hasMoreReels.hashCode ^
      mediaIndex.hashCode;

  @override
  String toString() {
    return 'ProfileState{' +
        ' loadStatus: $loadStatus,' +
        ' loadPostStatus: $loadPostStatus,' +
        ' loadReelStatus: $loadReelStatus,' +
        ' userProfile: $userProfile,' +
        ' userPosts: $userPosts,' +
        ' userReels: $userReels,' +
        ' errorMessage: $errorMessage,' +
        ' hasMorePosts: $hasMorePosts,' +
        ' hasMoreReels: $hasMoreReels,' +
        ' mediaIndex: $mediaIndex,' +
        '}';
  }

  ProfileState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? loadPostStatus,
    LoadStatus? loadReelStatus,
    Profile? userProfile,
    List<Post>? userPosts,
    List<Reel>? userReels,
    String? errorMessage,
    bool? hasMorePosts,
    bool? hasMoreReels,
    int? mediaIndex,
  }) {
    return ProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadPostStatus: loadPostStatus ?? this.loadPostStatus,
      loadReelStatus: loadReelStatus ?? this.loadReelStatus,
      userProfile: userProfile ?? this.userProfile,
      userPosts: userPosts ?? this.userPosts,
      userReels: userReels ?? this.userReels,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      hasMoreReels: hasMoreReels ?? this.hasMoreReels,
      mediaIndex: mediaIndex ?? this.mediaIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'loadPostStatus': this.loadPostStatus,
      'loadReelStatus': this.loadReelStatus,
      'userProfile': this.userProfile,
      'userPosts': this.userPosts,
      'userReels': this.userReels,
      'errorMessage': this.errorMessage,
      'hasMorePosts': this.hasMorePosts,
      'hasMoreReels': this.hasMoreReels,
      'mediaIndex': this.mediaIndex,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      loadStatus: map['loadStatus'] as LoadStatus,
      loadPostStatus: map['loadPostStatus'] as LoadStatus,
      loadReelStatus: map['loadReelStatus'] as LoadStatus,
      userProfile: map['userProfile'] as Profile,
      userPosts: map['userPosts'] as List<Post>,
      userReels: map['userReels'] as List<Reel>,
      errorMessage: map['errorMessage'] as String,
      hasMorePosts: map['hasMorePosts'] as bool,
      hasMoreReels: map['hasMoreReels'] as bool,
      mediaIndex: map['mediaIndex'] as int,
    );
  }

  //</editor-fold>
}
