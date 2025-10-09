import 'package:bloc/bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/services/repositories/hive/profile_repository.dart';
import 'package:social_media_app/services/repositories/shared_preference_repository.dart';

import '../../services/repositories/api/api.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  Api api;

  AuthenticationCubit(this.api) : super(AuthenticationState.init());

  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      await api.signInWithEmail(email, password);
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      await api.signUpWithEmail(email, password);
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), loadStatus: LoadStatus.error));
      throw Exception(e);
    }
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      await api.loginWithGoogle();
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loginWithFacebook() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      await api.loginWithFacebook();
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> createUserProfile() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final userProfile = await api.createProfile();
      final repo = ProfileRepository();
      repo.saveProfile(userProfile);
      await SharedPreferenceRepository.setLogin();
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
      throw Exception(e);
    }
  }

  Future<void> sentEmailConfirm(String email) async {
    try {
      await api.sendPasswordResetEmail(email);
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await api.updatePassword(newPassword);
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }
}
