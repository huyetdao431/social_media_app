import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/models/profile/profiles.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/services/repositories/hive/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  Api api;

  ProfileCubit(this.api) : super(ProfileState.init());

  void loadProfile(Profile userProfile) {
    emit(state.copyWith(userProfile: userProfile));
  }

  Future<String?> uploadAvatar(File file) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final avtUrl = await api.uploadFile(bucketName: 'avatars', file: file, userId: state.userProfile!.id);
      emit(state.copyWith(loadStatus: LoadStatus.done));
      return avtUrl;
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
    }
    return null;
  }

  Future<void> updateProfile(Profile newProfile) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final userProfile = await api.updateProfile(newProfile);
      final repo = ProfileRepository();
      await repo.saveProfile(userProfile);
      emit(state.copyWith(userProfile: userProfile, loadStatus: LoadStatus.done, errorMessage: 'Cập nhật profile thành công!'));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<bool> checkUsername(String username) async {
    bool result = false;
    try {
      result = await api.isExistUsername(username);
      return !result;
    } catch (e) {
      throw Exception(e);
    }
  }
}
