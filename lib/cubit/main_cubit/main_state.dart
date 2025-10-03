part of 'main_cubit.dart';

class MainState {
  final bool isLightTheme;
  final LoadStatus loadStatus;
  final Profile? profile;

  const MainState.init({
    this.isLightTheme = true,
    this.loadStatus = LoadStatus.init,
    this.profile,
  });

//<editor-fold desc="Data Methods">


  const MainState({
    required this.isLightTheme,
    required this.loadStatus,
    this.profile,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is MainState &&
              runtimeType == other.runtimeType &&
              isLightTheme == other.isLightTheme &&
              loadStatus == other.loadStatus &&
              profile == other.profile
          );


  @override
  int get hashCode =>
      isLightTheme.hashCode ^
      loadStatus.hashCode ^
      profile.hashCode;


  @override
  String toString() {
    return 'MainState{' +
        ' isLightTheme: $isLightTheme,' +
        ' loadStatus: $loadStatus,' +
        ' profile: $profile,' +
        '}';
  }


  MainState copyWith({
    bool? isLightTheme,
    LoadStatus? loadStatus,
    Profile? profile,
  }) {
    return MainState(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'isLightTheme': this.isLightTheme,
      'loadStatus': this.loadStatus,
      'profile': this.profile,
    };
  }

  factory MainState.fromMap(Map<String, dynamic> map) {
    return MainState(
      isLightTheme: map['isLightTheme'] as bool,
      loadStatus: map['loadStatus'] as LoadStatus,
      profile: map['profile'] as Profile,
    );
  }


//</editor-fold>
}
