part of 'authentication_cubit.dart';

class AuthenticationState {
  final LoadStatus loadStatus;
  final String errorMessage;

  const AuthenticationState.init({
    this.loadStatus = LoadStatus.init,
    this.errorMessage = '',
  });

//<editor-fold desc="Data Methods">


  const AuthenticationState({
    required this.loadStatus,
    required this.errorMessage,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is AuthenticationState &&
              runtimeType == other.runtimeType &&
              loadStatus == other.loadStatus &&
              errorMessage == other.errorMessage
          );


  @override
  int get hashCode =>
      loadStatus.hashCode ^
      errorMessage.hashCode;


  @override
  String toString() {
    return 'AuthenticationState{' +
        ' loadStatus: $loadStatus,' +
        ' errorMessage: $errorMessage,' +
        '}';
  }


  AuthenticationState copyWith({
    LoadStatus? loadStatus,
    String? errorMessage,
  }) {
    return AuthenticationState(
      loadStatus: loadStatus ?? this.loadStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'loadStatus': this.loadStatus,
      'errorMessage': this.errorMessage,
    };
  }

  factory AuthenticationState.fromMap(Map<String, dynamic> map) {
    return AuthenticationState(
      loadStatus: map['loadStatus'] as LoadStatus,
      errorMessage: map['errorMessage'] as String,
    );
  }


//</editor-fold>
}
