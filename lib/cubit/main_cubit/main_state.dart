part of 'main_cubit.dart';

class MainState {
  final bool isLightTheme;
  final LoadStatus loadStatus;
  final Profile? profile;
  final int selectedIndex;

  const MainState.init({
    this.isLightTheme = true,
    this.loadStatus = LoadStatus.init,
    this.profile,
    this.selectedIndex = 0,
  });

//<editor-fold desc="Data Methods">


  const MainState({
    required this.isLightTheme,
    required this.loadStatus,
    this.profile,
    required this.selectedIndex,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is MainState &&
              runtimeType == other.runtimeType &&
              isLightTheme == other.isLightTheme &&
              loadStatus == other.loadStatus &&
              profile == other.profile &&
              selectedIndex == other.selectedIndex
          );


  @override
  int get hashCode =>
      isLightTheme.hashCode ^
      loadStatus.hashCode ^
      profile.hashCode ^
      selectedIndex.hashCode;


  @override
  String toString() {
    return 'MainState{' +
        ' isLightTheme: $isLightTheme,' +
        ' loadStatus: $loadStatus,' +
        ' profile: $profile,' +
        ' selectedIndex: $selectedIndex,' +
        '}';
  }


  MainState copyWith({
    bool? isLightTheme,
    LoadStatus? loadStatus,
    Profile? profile,
    int? selectedIndex,
  }) {
    return MainState(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      loadStatus: loadStatus ?? this.loadStatus,
      profile: profile ?? this.profile,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'isLightTheme': this.isLightTheme,
      'loadStatus': this.loadStatus,
      'profile': this.profile,
      'selectedIndex': this.selectedIndex,
    };
  }

  factory MainState.fromMap(Map<String, dynamic> map) {
    return MainState(
      isLightTheme: map['isLightTheme'] as bool,
      loadStatus: map['loadStatus'] as LoadStatus,
      profile: map['profile'] as Profile,
      selectedIndex: map['selectedIndex'] as int,
    );
  }


//</editor-fold>
}
