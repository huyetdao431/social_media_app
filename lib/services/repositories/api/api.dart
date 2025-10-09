import 'dart:io';

import '../../../models/profile/profile.dart';
import '../../../models/post.dart';

abstract class Api {
  //<editor-fold desc="auth">

  Future<void> signInWithEmail(String email, String password);

  Future<void> signUpWithEmail(String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> loginWithGoogle();

  Future<void> loginWithFacebook();

  Future<void> logout();

  //</editor-fold>

  //<editor-fold desc="profile">

  Future<Profile> createProfile();

  Future<String> ensureUniqueUsername(String base);

  Future<bool> isExistUsername(String username);

  Future<Profile?> getProfile(String id);

  Future<String> uploadFile({required String bucketName, required File file, required String userId, String? folder});

  Future<Profile> updateProfile(Profile newProfile);

  Future<void> deleteProfile(String id);

  //</editor-fold>

  //<editor-fold desc="post">

  Future<String?> generateVideoThumb(String bucketName, File videoFile, String userId);

  Future<String> createPost({required String userId, required String caption, required List<File> files, required double aspectRatio});

  Future<Post?> getPost(String postId);

  Future<void> updatePostStatus(String postId, String status);

  Future<void> deletePost(String postId, String userId);

  Future<List<Post>> getPostsByUser({required String userId, int limit = 12, int offset = 0});

  //</editor-fold>

}
