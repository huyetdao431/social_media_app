import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/services/repositories/log/log.dart';
import 'package:social_media_app/utils/get_video_duration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/comment.dart';
import '../../../models/post_media.dart';
import '../../../models/post.dart';
import '../../../models/profile/profile.dart';
import '../../../models/reel.dart';
import '../../../models/story.dart';
import '../../../utils/map_login_errors.dart';

class ApiImpl implements Api {
  Log log;

  ApiImpl(this.log);

  final supabase = Supabase.instance.client;

  //<editor-fold desc="login methods">
  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);

      if (response.session != null) {
        print("Đăng nhập thành công!");
      } else {
        print("Đăng nhập thất bại: ${response.session}");
      }
    } on AuthException catch (e) {
      final errorMessage = mapAuthExceptionMessage(e, provider: 'Email');
      print(e);
      throw errorMessage;
    } catch (e) {
      print(e);
      throw 'Đăng nhập bằng Google thất bại: ${e.toString()}';
    }
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);

      if (response.user != null) {
        print("Đăng ký thành công! Kiểm tra email để xác minh.");
      } else {
        print("Đăng ký thất bại: ${response.session}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email, redirectTo: 'myapp://password-reset-callback');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> loginWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook, redirectTo: 'myapp://auth-callback', authScreenLaunchMode: LaunchMode.externalApplication);
    } on AuthException catch (e) {
      final errorMessage = mapAuthExceptionMessage(e, provider: 'Facebook');
      throw errorMessage;
    } catch (e) {
      throw 'Đăng nhập bằng Facebook thất bại.';
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      const webClientId = '193704256783-obenl9l7r5bbg19l5jb7ltdk9g019ouv.apps.googleusercontent.com';
      // const iosClientId = '193704256783-qevd2nv3vv1u37aa33ine17j5qgrt85m.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, accessToken: accessToken);

      if (response.user != null) {
        print('Supabase login Google thành công: ${response.user!.email}');
      } else {
        print('Supabase login Google thất bại');
      }
    } on AuthException catch (e) {
      final errorMessage = mapAuthExceptionMessage(e, provider: 'Google');
      throw errorMessage;
    } catch (e) {
      // throw 'Đăng nhập bằng Google thất bại.';
      throw Exception(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      debugPrint("Đăng xuất thành công");
    } catch (e, st) {
      debugPrint("Lỗi khi đăng xuất: $e\n$st");
    }
  }

  //</editor-fold>

  //<editor-fold desc="profile methods">
  @override
  Future<Profile> createProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final id = user.id;

    final existing = await supabase.from('profiles').select().eq('id', id).maybeSingle();

    if (existing != null) {
      return Profile.fromMap(existing);
    }

    final provider = (user.appMetadata['provider'] ?? '').toString().toLowerCase();

    String baseUsername = '';
    final email = user.email;
    if (email != null && email.contains('@')) {
      baseUsername = email.split('@').first;
    } else {
      baseUsername = id.replaceAll('-', '').substring(0, 8); // fallback short id
    }

    baseUsername = baseUsername.trim().toLowerCase();

    final username = await ensureUniqueUsername(baseUsername);
    String displayName = username;
    if (provider != 'email' && provider.isNotEmpty) {
      final userMeta = user.userMetadata;
      dynamic raw = userMeta?['raw_user_meta_data'] ?? userMeta;
      displayName =
          (raw is Map)
              ? (raw['name'] ?? raw['full_name'] ?? raw['given_name'] ?? raw['displayName'] ?? raw['username'] ?? username).toString()
              : (userMeta?['name']?.toString() ?? username);
    }

    String avatarUrl = '';
    final userMeta = user.userMetadata;
    if (userMeta != null) {
      final raw = userMeta['raw_user_meta_data'] ?? userMeta;
      if (raw is Map) {
        avatarUrl = (raw['picture'] ?? raw['avatar_url'] ?? raw['avatar'] ?? raw['image'])?.toString() ?? '';
      }
      avatarUrl = avatarUrl.isEmpty ? (userMeta['picture'] ?? userMeta['avatar_url'] ?? userMeta['avatar'])?.toString() ?? '' : avatarUrl;
    }

    final nowIso = DateTime.now().toUtc().toIso8601String();

    final insertPayload = {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': '',
      'is_public': true,
      'created_at': nowIso,
      'updated_at': nowIso,
      'username_changed_at': nowIso,
      'displayname_changed_at': nowIso,
    };

    final inserted = await supabase.from('profiles').insert(insertPayload).select().maybeSingle();

    if (inserted == null) {
      throw Exception('Failed to create profile.');
    }

    return Profile.fromMap(inserted);
  }

  @override
  Future<String> ensureUniqueUsername(String base) async {
    var candidate = base;
    var suffix = 0;
    while (true) {
      final existing = await supabase.from('profiles').select('id').eq('username', candidate).maybeSingle();

      if (existing == null) {
        return candidate;
      }

      suffix++;
      candidate = '$base$suffix';
      if (suffix > 1000) {
        candidate = '${base}_${DateTime.now().millisecondsSinceEpoch}';
        return candidate;
      }
    }
  }

  @override
  Future<bool> isExistUsername(String username) async {
    final existing = await supabase.from('profiles').select('id').eq('username', username).maybeSingle();
    return existing != null;
  }

  @override
  Future<Profile?> getProfile(String id) async {
    final res = await supabase.from('profiles').select().eq('id', id).maybeSingle();

    if (res == null) return null;
    return Profile.fromMap(res);
  }

  @override
  Future<Profile> updateProfile(Profile newProfile) async {
    final oldProfile = await getProfile(newProfile.id);
    if (oldProfile == null) throw Exception('Profile not found');

    final payload = <String, dynamic>{};

    if (newProfile.username != oldProfile.username) {
      payload['username'] = newProfile.username;
    }

    if (newProfile.displayName != oldProfile.displayName) {
      payload['display_name'] = newProfile.displayName;
    }
    if (newProfile.bio != oldProfile.bio) {
      payload['bio'] = newProfile.bio;
    }
    if (newProfile.avatarUrl != oldProfile.avatarUrl) {
      payload['avatar_url'] = newProfile.avatarUrl;
    }
    if (newProfile.isPublic != oldProfile.isPublic) {
      payload['is_public'] = newProfile.isPublic;
    }
    if (payload.isEmpty) {
      return oldProfile;
    }
    final resp = await supabase.from('profiles').update(payload).eq('id', newProfile.id).select().maybeSingle();

    if (resp == null) throw 'Failed to update profile';

    return Profile.fromMap(resp);
  }

  @override
  Future<void> deleteProfile(String id) async {
    final res = await supabase.from('profiles').delete().eq('id', id);
    if (res == null) {
      throw 'Failed to delete profile';
    }
  }

  //</editor-fold>

  //<editor-fold desc="post's methods">
  @override
  Future<String> uploadFile({required String bucketName, required File file, required String userId, String? folder}) async {
    try {
      final fileExt = p.extension(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'file-$timestamp$fileExt';

      final filePath = folder != null && folder.isNotEmpty ? '$folder/$userId/$fileName' : '$userId/$fileName';

      // Upload lên bucket
      final storage = supabase.storage.from(bucketName);
      await storage.upload(filePath, file, fileOptions: const FileOptions(upsert: true));

      // Lấy public URL
      final publicUrl = storage.getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Lỗi upload file lên bucket $bucketName: $e');
    }
  }

  @override
  Future<String?> generateVideoThumb(String bucketName, File videoFile, String userId) async {
    try {
      final dir = await getTemporaryDirectory();
      final thumbPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';

      final command = '-i "${videoFile.path}" -ss 00:00:01 -vframes 1 -q:v 2 "$thumbPath"';
      final session = await FFmpegKit.execute(command);

      final returnCode = await session.getReturnCode();
      if (returnCode?.isValueSuccess() != true) {
        print('Error: FFmpeg failed: ${await session.getOutput()}');
        return null;
      }

      final thumbFile = File(thumbPath);
      final thumbUrl = await uploadFile(bucketName: bucketName, file: thumbFile, userId: userId, folder: 'thumbnails');

      return thumbUrl;
    } catch (e, st) {
      print('Error generating thumbnail: $e\n$st');
      return null;
    }
  }

  @override
  Future<String> createPost({required String userId, required String caption, required List<File> files, required double aspectRatio}) async {
    if (files.isEmpty) return '';

    final List<Map<String, dynamic>> medias = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final publicUrl = await uploadFile(bucketName: 'posts', file: file, userId: userId, folder: 'posts');

      final mimeType = lookupMimeType(file.path);
      final isVideo = mimeType != null && mimeType.startsWith('video');
      final duration = isVideo ? await getVideoDuration(file.path) : null;
      String? thumbUrl;

      if (isVideo) {
        thumbUrl = await generateVideoThumb('posts', file, userId);
      } else {
        thumbUrl = null;
      }

      medias.add({
        'media_url': publicUrl,
        'media_type': isVideo ? 'video' : 'image',
        'order_index': i,
        'is_primary': i == 0,
        'mime_type': mimeType,
        'file_size': await file.length(),
        'duration': duration,
        'thumb_url': thumbUrl,
      });
    }

    final rpcRes = await supabase.rpc(
      'create_post_with_media',
      params: {'p_user_id': userId, 'p_caption': caption, 'p_medias': medias, 'p_status': 'published', 'p_aspect_ratio': aspectRatio},
    );

    if (rpcRes == null) {
      throw Exception('Create post failed: RPC returned null');
    }

    final createdPostId = (rpcRes as List).first['post_id'] as String;
    print('Post created successfully with ID: $createdPostId');
    return createdPostId;
  }

  @override
  Future<Post?> getPost(String postId) async {
    final response = await supabase.from('posts').select('*, post_media(*)').eq('id', postId).maybeSingle();

    if (response == null) return null;

    final List<PostMedia> mediaList = (response['post_media'] as List<dynamic>).map((m) => PostMedia.fromMap(m as Map<String, dynamic>)).toList();

    return Post.fromMap({...response, 'media_list': mediaList});
  }

  @override
  Future<List<Post>> getPostsByUser({required String userId, int limit = 12, int offset = 0}) async {
    try {
      final response = await supabase
          .from('posts')
          .select('*, post_media(*)')
          .eq('user_id', userId)
          .neq('status', 'pending_delete')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (response.isEmpty) return [];
      List<Post> results =
          response.map<Post>((map) {
            final List<PostMedia> mediaList = (map['post_media'] as List<dynamic>).map((m) => PostMedia.fromMap(m as Map<String, dynamic>)).toList();

            return Post.fromMap({...map, 'media_list': mediaList});
          }).toList();
      return results;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> updatePostStatus(String postId, String status) async {
    await supabase.from('posts').update({'status': status, 'updated_at': DateTime.now().toIso8601String()}).eq('id', postId);
  }

  @override
  Future<void> deletePost(String postId, String userId) async {
    await supabase.from('posts').update({'status': 'pending_delete', 'updated_at': DateTime.now().toIso8601String()}).eq('id', postId);

    await supabase.rpc('decrease_post_count', params: {'user_id': userId});
  }

  //</editor-fold>

  //<editor-fold desc="comment's methods">

  @override
  Future<List<Comment>> getComments({required String targetType, required String targetId, int limit = 20, int offset = 0}) async {
    final res = await supabase
        .from('comments')
        .select(
          'id, target_type, target_id, user_id, parent_id, content, created_at, updated_at, reply_count, like_count, profiles(id, display_name, avatar_url)',
        )
        .eq('target_type', targetType)
        .eq('target_id', targetId)
        .isFilter('parent_id', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final data = res as List<dynamic>? ?? [];
    return data.map((e) => Comment.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<List<Comment>> getReplies({required String commentId, int limit = 5}) async {
    final res = await supabase
        .from('comments')
        .select(
          'id, target_type, target_id, user_id, parent_id, content, created_at, updated_at, reply_count, like_count, profiles(id, display_name, avatar_url)',
        )
        .eq('parent_id', commentId)
        .order('created_at', ascending: true)
        .limit(limit);

    final data = res as List<dynamic>? ?? [];
    return data.map((e) => Comment.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<Comment> createComment({
    required String targetType,
    required String targetId,
    required String userId,
    required String content,
    String? parentId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final insertMap = {
      'target_type': targetType,
      'target_id': targetId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'created_at': now,
      'updated_at': null,
      'reply_count': 0,
      'like_count': 0,
    };

    final insertRes =
        await supabase
            .from('comments')
            .insert(insertMap)
            .select(
              'id, target_type, target_id, user_id, parent_id, content, created_at, updated_at, reply_count, like_count, profiles(id, display_name, avatar_url)',
            )
            .single();

    final newComment = Comment.fromMap(Map<String, dynamic>.from(insertRes as Map));

    // Nếu là reply -> tăng reply_count cho comment cha
    if (parentId != null) {
      try {
        final parentSel = await supabase.from('comments').select('reply_count').eq('id', parentId).single();

        if (parentSel['reply_count'] != null) {
          final current = parentSel['reply_count'] is int ? parentSel['reply_count'] as int : int.tryParse('${parentSel['reply_count']}') ?? 0;

          await supabase.from('comments').update({'reply_count': current + 1}).eq('id', parentId);
        }
      } catch (e) {
        throw Exception(e);
      }
    }

    return newComment;
  }

  @override
  Future<Comment> updateComment({required String commentId, required String userId, required String newContent}) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final res =
        await supabase
            .from('comments')
            .update({'content': newContent, 'updated_at': now})
            .eq('id', commentId)
            .eq('user_id', userId)
            .select(
              'id, target_type, target_id, user_id, parent_id, content, created_at, updated_at, reply_count, like_count, profiles(id, display_name, avatar_url)',
            )
            .single();

    return Comment.fromMap(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<bool> deleteComment({required String commentId, required String userId}) async {
    final sel = await supabase.from('comments').select('id, parent_id, user_id').eq('id', commentId).single();

    if (sel['user_id'] != userId) {
      throw Exception('Bạn không có quyền xóa comment này');
    }

    final parentId = sel['parent_id'] as String?;

    await supabase.from('comments').delete().eq('id', commentId);

    if (parentId != null) {
      try {
        final parentSel = await supabase.from('comments').select('reply_count').eq('id', parentId).single();

        if (parentSel['reply_count'] != null) {
          final current = parentSel['reply_count'] is int ? parentSel['reply_count'] as int : int.tryParse('${parentSel['reply_count']}') ?? 0;

          final newCount = current > 0 ? current - 1 : 0;

          await supabase.from('comments').update({'reply_count': newCount}).eq('id', parentId);
        }
      } catch (e) {
        throw Exception(e);
      }
    }
    return true;
  }

  //</editor-fold>

  //<editor-fold desc="story's methods">

  @override
  Future<Story> createStory({required File file, required DateTime expiresAt, String visibility = 'public'}) async {
    try {
      final String userId = supabase.auth.currentUser!.id;
      final publicUrl = await uploadFile(bucketName: 'stories', file: file, userId: userId, folder: 'stories');

      final mimeType = lookupMimeType(file.path);
      final isVideo = mimeType != null && mimeType.startsWith('video');
      final int duration = isVideo ? await getVideoDuration(file.path) : 10;
      final thumbUrl = isVideo ? await generateVideoThumb('stories', file, userId) : null;

      final insertBody = {
        'user_id': userId,
        'media_url': publicUrl,
        'media_type': isVideo ? 'video' : 'image',
        'expires_at': expiresAt.toUtc().toIso8601String(),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'mime_type': mimeType,
        'duration': duration,
        'thumb_url': thumbUrl,
        'visibility': visibility,
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'view_count': 0,
      };

      final res = await supabase.from('stories').insert(insertBody).select();
      final createdMap = (res as List).first as Map<String, dynamic>;
      return Story.fromMap(createdMap);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when creating story: ${e.message}');
    } catch (e) {
      throw Exception('Create story failed: $e');
    }
  }

  @override
  Future<Story?> getStory(String storyId, String currentUserId) async {
    try {
      final res =
          await supabase
              .from('stories')
              .select('*, profiles(username, avatar_url), story_views!left(viewer_id)')
              .eq('id', storyId)
              .eq('story_views.viewer_id', currentUserId)
              .maybeSingle();

      if (res == null) return null;
      return Story.fromMap(Map<String, dynamic>.from(res as Map));
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when getting story: ${e.message}');
    } catch (e) {
      throw Exception('Get story failed: $e');
    }
  }

  @override
  Future<List<Story>> getStoriesByUser({required String userId, int limit = 12, int offset = 0}) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final currentUserId = supabase.auth.currentUser!.id;

      final res = await supabase
          .from('stories')
          .select('*, profiles(username, avatar_url), story_views!left(viewer_id)')
          .eq('user_id', userId)
          .eq('is_active', true)
          .neq('visibility', 'disabled')
          .gt('expires_at', now)
          .eq('story_views.viewer_id', currentUserId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      final List rows = res as List;
      return rows.map((r) => Story.fromMap(Map<String, dynamic>.from(r as Map))).toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when listing stories by user: ${e.message}');
    } catch (e) {
      throw Exception('Get stories by user failed: $e');
    }
  }

  @override
  Future<List<Story>> getFeedStories({int limit = 50, int offset = 0}) async {
    try {
      final currentUserId = supabase.auth.currentUser!.id;
      final res = await supabase.rpc('get_feed_stories', params: {'p_viewer': currentUserId, 'p_limit': limit, 'p_offset': offset});

      final List rows = (res == null) ? [] : (res as List);
      return rows.map((r) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(r as Map);
        return Story.fromMap(m);
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase RPC error: ${e.message}');
    } catch (e) {
      throw Exception('getFeedStoriesRpc failed: $e');
    }
  }

  @override
  Future<Story> updateStoryStatus({required String storyId, bool? isActive, String? visibility}) async {
    try {
      final patch = {'is_active': isActive ?? true, 'visibility': visibility ?? 'public', 'updated_at': DateTime.now().toUtc().toIso8601String()};

      final res = await supabase.from('stories').update(patch).eq('id', storyId).select();
      final List rows = res as List;
      if (rows.isEmpty) {
        throw Exception('No story updated (id not found or permission denied)');
      }
      final updatedMap = Map<String, dynamic>.from(rows.first as Map);
      return Story.fromMap(updatedMap);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when updating story: ${e.message}');
    } catch (e) {
      throw Exception('Update story failed: $e');
    }
  }

  @override
  Future<bool> deleteStorySoft({required String storyId}) async {
    try {
      final patch = {'visibility': 'disabled', 'is_active': false, 'updated_at': DateTime.now().toUtc().toIso8601String()};

      final res = await supabase.from('stories').update(patch).eq('id', storyId).select();
      final List rows = res as List;
      return rows.isNotEmpty;
    } on PostgrestException {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> addStoryView({required String storyId, required String viewerId, String? deviceInfo}) async {
    try {
      await supabase.from('story_views').insert({
        'story_id': storyId,
        'viewer_id': viewerId,
        'device_info': deviceInfo ?? '',
        'viewed_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when inserting story view: ${e.message}');
    } catch (e) {
      throw Exception('Failed to insert story view: $e');
    }
  }

  //</editor-fold>

  //<editor-fold  desc="reel's methods">

  @override
  Future<Reel> createReel({required File file, String caption = '', bool isPublic = true}) async {
    try {
      final String userId = supabase.auth.currentUser!.id;
      final publicUrl = await uploadFile(bucketName: 'reels', file: file, userId: userId, folder: 'reels');

      final mimeType = lookupMimeType(file.path);
      final int duration = await getVideoDuration(file.path);
      final poster = await generateVideoThumb('reels', file, userId);

      final insertBody = {
        'user_id': userId,
        'media_url': publicUrl,
        'poster_url': poster,
        'caption': caption,
        'is_public': isPublic,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'mime_type': mimeType,
        'duration': duration,
        'view_count': 0,
        'like_count': 0,
        'comment_count': 0,
      };

      final res = await supabase.from('reels').insert(insertBody).select();
      final createdMap = (res as List).first as Map<String, dynamic>;
      return Reel.fromMap(Map<String, dynamic>.from(createdMap));
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when creating reel: ${e.message}');
    } catch (e) {
      throw Exception('Create reel failed: $e');
    }
  }

  @override
  Future<Reel?> getReel(String reelId, {String? currentUserId}) async {
    try {
      final res = await supabase.from('reels').select('*, profiles(username, avatar_url)').eq('id', reelId).maybeSingle();

      if (res == null) return null;
      return Reel.fromMap(Map<String, dynamic>.from(res as Map));
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when getting reel: ${e.message}');
    } catch (e) {
      throw Exception('Get reel failed: $e');
    }
  }

  @override
  Future<List<Reel>> getReelsByUser({required String userId, int limit = 12, int offset = 0}) async {
    try {
      final query = supabase
          .from('reels')
          .select('*, profiles(username, avatar_url)')
          .eq('user_id', userId)
          .eq('is_public', true)
          .order('created_at', ascending: false);
      final res = await query.range(offset, offset + limit - 1);

      final List rows = res as List;
      return rows.map((r) => Reel.fromMap(Map<String, dynamic>.from(r as Map))).toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when listing reels by user: ${e.message}');
    } catch (e) {
      throw Exception('Get reels by user failed: $e');
    }
  }

  @override
  Future<List<Reel>> getFeedReels({int limit = 12, int offset = 0}) async {
    try {
      final currentUserId = supabase.auth.currentUser!.id;
      final res = await supabase.rpc('get_feed_reels', params: {'p_viewer': currentUserId, 'p_limit': limit, 'p_offset': offset});

      final List rows = (res == null) ? [] : (res as List);
      return rows.map((r) => Reel.fromMap(Map<String, dynamic>.from(r as Map))).toList();
    } on PostgrestException catch (e) {
      throw Exception('Supabase RPC error: ${e.message}');
    } catch (e) {
      throw Exception('getFeedReelsRpc failed: $e');
    }
  }

  @override
  Future<Reel> updateReelStatus({required String reelId, bool? isPublic}) async {
    try {
      final patch = {if (isPublic != null) 'is_public': isPublic, 'updated_at': DateTime.now().toUtc().toIso8601String()};

      final res = await supabase.from('reels').update(patch).eq('id', reelId).select();
      final List rows = res as List;
      if (rows.isEmpty) {
        throw Exception('No reel updated (id not found or permission denied)');
      }
      final updatedMap = Map<String, dynamic>.from(rows.first as Map);
      return Reel.fromMap(updatedMap);
    } on PostgrestException catch (e) {
      throw Exception('Supabase error when updating reel: ${e.message}');
    } catch (e) {
      throw Exception('Update reel failed: $e');
    }
  }

  @override
  Future<bool> deleteReelSoft({required String reelId}) async {
    try {
      final patch = {'is_public': false, 'updated_at': DateTime.now().toUtc().toIso8601String()};

      final res = await supabase.from('reels').update(patch).eq('id', reelId).select();
      final List rows = res as List;
      return rows.isNotEmpty;
    } on PostgrestException {
      return false;
    } catch (e) {
      return false;
    }
  }

  //</editor-fold>
}
