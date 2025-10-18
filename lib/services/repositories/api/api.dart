import 'dart:io';

import '../../../models/comment.dart';
import '../../../models/profile/profile.dart';
import '../../../models/post.dart';
import '../../../models/reel.dart';
import '../../../models/story.dart';

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

  //<editor-fold desc="comment">
  Future<List<Comment>> getComments({required String targetType, required String targetId, int limit = 20, int offset = 0});

  Future<List<Comment>> getReplies({required String commentId, int limit = 5});

  Future<Comment> createComment({required String targetType, required String targetId, required String userId, required String content, String? parentId});

  Future<Comment> updateComment({required String commentId, required String userId, required String newContent});

  Future<bool> deleteComment({required String commentId, required String userId});

  //</editor-fold>

  //<editor-fold desc="story's methods">
  Future<Story> createStory({required File file, required DateTime expiresAt, String visibility = 'public'});

  Future<Story?> getStory(String storyId, String currentUserId);

  Future<List<Story>> getStoriesByUser({required String userId, int limit = 12, int offset = 0});

  Future<List<Story>> getFeedStories({int limit = 50, int offset = 0});

  Future<Story> updateStoryStatus({required String storyId, bool? isActive, String? visibility});

  Future<bool> deleteStorySoft({required String storyId});

  Future<void> addStoryView({required String storyId, required String viewerId, String? deviceInfo});

  //</editor-fold>

  //<editor-fold desc="reel's methods">
  Future<Reel> createReel({required File file, String caption = '', bool isPublic = true});

  Future<Reel?> getReel(String reelId, {String? currentUserId});

  Future<List<Reel>> getReelsByUser({required String userId, int limit = 12, int offset = 0});

  Future<List<Reel>> getFeedReels({int limit = 12, int offset = 0});

  Future<Reel> updateReelStatus({required String reelId, bool? isPublic});

  Future<bool> deleteReelSoft({required String reelId});
  //</editor-fold>
}
