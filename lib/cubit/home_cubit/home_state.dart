part of 'home_cubit.dart';

class HomeState {
  final LoadStatus loadStatus;

  const HomeState.init({
    this.loadStatus = LoadStatus.init,
  });

  //<editor-fold desc="Data Methods">
  const HomeState({
    required this.loadStatus,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is HomeState &&
              runtimeType == other.runtimeType &&
              loadStatus == other.loadStatus
          );


  @override
  int get hashCode =>
      loadStatus.hashCode;


  @override
  String toString() {
    return 'HomeState{' +
        ' loadStatus: $loadStatus,' +
        '}';
  }


  HomeState copyWith({
    LoadStatus? loadStatus,
  }) {
    return HomeState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
    };
  }

  factory HomeState.fromMap(Map<String, dynamic> map) {
    return HomeState(
      loadStatus: map['loadStatus'] as LoadStatus,
    );
  }


//</editor-fold>
}
