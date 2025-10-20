part of 'reel_bloc.dart';

class ReelState {
  final LoadStatus loadStatus;
  final LoadStatus loadReelStatus;
  final LoadStatus loadMoreStatus;
  final File? reelMedia;
  final String errorMessage;
  final List<Reel> userReels;
  final List<Reel> currentReels;
  final List<Reel> followingReels;

  const ReelState.init({
    this.loadStatus = LoadStatus.init,
    this.loadReelStatus = LoadStatus.init,
    this.loadMoreStatus = LoadStatus.init,
    this.reelMedia,
    this.errorMessage = '',
    this.userReels = const [],
    this.currentReels = const [],
    this.followingReels = const [],
  });

  //<editor-fold desc="Data Methods">
  const ReelState({
    required this.loadStatus,
    required this.loadReelStatus,
    required this.loadMoreStatus,
    this.reelMedia,
    required this.errorMessage,
    required this.userReels,
    required this.currentReels,
    required this.followingReels,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReelState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          loadReelStatus == other.loadReelStatus &&
          loadMoreStatus == other.loadMoreStatus &&
          reelMedia == other.reelMedia &&
          errorMessage == other.errorMessage &&
          userReels == other.userReels &&
          currentReels == other.currentReels &&
          followingReels == other.followingReels);

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      loadReelStatus.hashCode ^
      loadMoreStatus.hashCode ^
      reelMedia.hashCode ^
      errorMessage.hashCode ^
      userReels.hashCode ^
      currentReels.hashCode ^
      followingReels.hashCode;

  @override
  String toString() {
    return 'ReelState{' +
        ' loadStatus: $loadStatus,' +
        ' loadReelStatus: $loadReelStatus,' +
        ' loadMoreStatus: $loadMoreStatus,' +
        ' reelMedia: $reelMedia,' +
        ' errorMessage: $errorMessage,' +
        ' userReels: $userReels,' +
        ' currentReels: $currentReels,' +
        ' followingReels: $followingReels,' +
        '}';
  }

  ReelState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? loadReelStatus,
    LoadStatus? loadMoreStatus,
    File? reelMedia,
    String? errorMessage,
    List<Reel>? userReels,
    List<Reel>? currentReels,
    List<Reel>? followingReels,
  }) {
    return ReelState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadReelStatus: loadReelStatus ?? this.loadReelStatus,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      reelMedia: reelMedia ?? this.reelMedia,
      errorMessage: errorMessage ?? this.errorMessage,
      userReels: userReels ?? this.userReels,
      currentReels: currentReels ?? this.currentReels,
      followingReels: followingReels ?? this.followingReels,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'loadReelStatus': this.loadReelStatus,
      'loadMoreStatus': this.loadMoreStatus,
      'reelMedia': this.reelMedia,
      'errorMessage': this.errorMessage,
      'userReels': this.userReels,
      'currentReels': this.currentReels,
      'followingReels': this.followingReels,
    };
  }

  factory ReelState.fromMap(Map<String, dynamic> map) {
    return ReelState(
      loadStatus: map['loadStatus'] as LoadStatus,
      loadReelStatus: map['loadReelStatus'] as LoadStatus,
      loadMoreStatus: map['loadMoreStatus'] as LoadStatus,
      reelMedia: map['reelMedia'] as File,
      errorMessage: map['errorMessage'] as String,
      userReels: map['userReels'] as List<Reel>,
      currentReels: map['currentReels'] as List<Reel>,
      followingReels: map['followingReels'] as List<Reel>,
    );
  }

  //</editor-fold>
}
