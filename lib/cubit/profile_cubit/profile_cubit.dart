import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/profile/profile.dart';
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

  Future<void> loadUserPosts() async {
    emit(state.copyWith(loadPostStatus: LoadStatus.loading));
    try {
      final List<Post> userPosts = await api.getPostsByUser(userId: state.userProfile!.id);
      emit(state.copyWith(loadPostStatus: LoadStatus.done, userPosts: userPosts));
    } catch (e) {
      emit(state.copyWith(loadPostStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> loadMoreUserPosts() async {
    if (state.loadPostStatus == LoadStatus.loading || !state.hasMorePosts) return;

    emit(state.copyWith(loadPostStatus: LoadStatus.loading));
    try {
      final offset = state.userPosts.length;
      const limit = 6;
      final nextPosts = await api.getPostsByUser(userId: state.userProfile!.id, limit: limit, offset: offset);
      final bool hasMore = nextPosts.length == limit;
      if (nextPosts.isEmpty) {
        emit(state.copyWith(loadPostStatus: LoadStatus.done, hasMorePosts: false));
        return;
      }
      final updatedPosts = List<Post>.from(state.userPosts)..addAll(nextPosts);
      emit(state.copyWith(loadPostStatus: LoadStatus.done, userPosts: updatedPosts, hasMorePosts: hasMore));
    } catch (e) {
      emit(state.copyWith(loadPostStatus: LoadStatus.error, errorMessage: e.toString(), hasMorePosts: false));
    }
  }

  void setMediaIndex (int index) {
    emit(state.copyWith(mediaIndex: index));
  }
}
