part of 'profile_cubit.dart';

class ProfileState {
  final LoadStatus loadStatus;
  final Profile? userProfile;
  final String errorMessage;

  const ProfileState.init({
    this.loadStatus = LoadStatus.init,
    this.userProfile,
    this.errorMessage = '',
  });

//<editor-fold desc="Data Methods">


  const ProfileState({
    required this.loadStatus,
    this.userProfile,
    required this.errorMessage,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is ProfileState &&
              runtimeType == other.runtimeType &&
              loadStatus == other.loadStatus &&
              userProfile == other.userProfile &&
              errorMessage == other.errorMessage
          );


  @override
  int get hashCode =>
      loadStatus.hashCode ^
      userProfile.hashCode ^
      errorMessage.hashCode;


  @override
  String toString() {
    return 'ProfileState{' +
        ' loadStatus: $loadStatus,' +
        ' userProfile: $userProfile,' +
        ' errorMessage: $errorMessage,' +
        '}';
  }


  ProfileState copyWith({
    LoadStatus? loadStatus,
    Profile? userProfile,
    String? errorMessage,
  }) {
    return ProfileState(
      loadStatus: loadStatus ?? this.loadStatus,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'userProfile': this.userProfile,
      'errorMessage': this.errorMessage,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      loadStatus: map['loadStatus'] as LoadStatus,
      userProfile: map['userProfile'] as Profile,
      errorMessage: map['errorMessage'] as String,
    );
  }


//</editor-fold>
}
