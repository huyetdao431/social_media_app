import 'dart:io';

import '../../../models/profile/profiles.dart';

abstract class Api {
  //auth
  Future<void> signInWithEmail(String email, String password);

  Future<void> signUpWithEmail(String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> loginWithGoogle();

  Future<void> loginWithFacebook();

  Future<void> logout();

  Future<Profile> createProfile();

  Future<String> ensureUniqueUsername(String base);

  Future<bool> isExistUsername(String username);

  Future<Profile?> getProfile(String id);

  Future<String> uploadFile({required String bucketName, required File file, required String userId, String? folder});

  Future<Profile> updateProfile(Profile newProfile);

  Future<void> deleteProfile(String id);

  Future<String?> generateVideoThumb(String bucketName, File videoFile, String userId);

  Future<void> createPostWithFiles({required String userId, required String caption, required List<File> files});
}
