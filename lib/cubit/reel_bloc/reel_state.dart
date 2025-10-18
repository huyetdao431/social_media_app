part of 'reel_bloc.dart';

class ReelState {
  final LoadStatus loadReelStatus;
  final LoadStatus loadMoreStatus;
  final String errorMessage;
  final List<Reel> userReels;
  final List<Reel> currentReels;
  final List<Reel> followingReels;

  const ReelState.init({
    this.loadReelStatus = LoadStatus.init,
    this.loadMoreStatus = LoadStatus.init,
    this.errorMessage = '',
    this.userReels = const [],
    this.currentReels = const [],
    this.followingReels = const [],
  });

  //<editor-fold desc="Data Methods">
  const ReelState({
    required this.loadReelStatus,
    required this.loadMoreStatus,
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
          loadReelStatus == other.loadReelStatus &&
          loadMoreStatus == other.loadMoreStatus &&
          errorMessage == other.errorMessage &&
          userReels == other.userReels &&
          currentReels == other.currentReels &&
          followingReels == other.followingReels);

  @override
  int get hashCode =>
      loadReelStatus.hashCode ^ loadMoreStatus.hashCode ^ errorMessage.hashCode ^ userReels.hashCode ^ currentReels.hashCode ^ followingReels.hashCode;

  @override
  String toString() {
    return 'ReelState{' +
        ' loadReelStatus: $loadReelStatus,' +
        ' loadMoreStatus: $loadMoreStatus,' +
        ' errorMessage: $errorMessage,' +
        ' userReels: $userReels,' +
        ' currentReels: $currentReels,' +
        ' followingReels: $followingReels,' +
        '}';
  }

  ReelState copyWith({
    LoadStatus? loadReelStatus,
    LoadStatus? loadMoreStatus,
    String? errorMessage,
    List<Reel>? userReels,
    List<Reel>? currentReels,
    List<Reel>? followingReels,
  }) {
    return ReelState(
      loadReelStatus: loadReelStatus ?? this.loadReelStatus,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      userReels: userReels ?? this.userReels,
      currentReels: currentReels ?? this.currentReels,
      followingReels: followingReels ?? this.followingReels,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loadReelStatus': this.loadReelStatus,
      'loadMoreStatus': this.loadMoreStatus,
      'errorMessage': this.errorMessage,
      'userReels': this.userReels,
      'currentReels': this.currentReels,
      'followingReels': this.followingReels,
    };
  }

  factory ReelState.fromMap(Map<String, dynamic> map) {
    return ReelState(
      loadReelStatus: map['loadReelStatus'] as LoadStatus,
      loadMoreStatus: map['loadMoreStatus'] as LoadStatus,
      errorMessage: map['errorMessage'] as String,
      userReels: map['userReels'] as List<Reel>,
      currentReels: map['currentReels'] as List<Reel>,
      followingReels: map['followingReels'] as List<Reel>,
    );
  }

  //</editor-fold>
}
