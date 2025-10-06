import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/services/repositories/log/log.dart';
import 'package:social_media_app/utils/get_video_duration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../models/profile/profiles.dart';
import '../../../utils/map_login_errors.dart';
import '../../../utils/utils.dart';

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
      throw 'Đăng nhập bằng Google thất bại.';
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

    // 1) If profile exists, return it
    final existing = await supabase.from('profiles').select().eq('id', id).maybeSingle();

    if (existing != null) {
      return Profile.fromMap(existing);
    }

    // 2) Determine provider
    final provider = (user.appMetadata['provider'] ?? '').toString().toLowerCase();

    // 3) Username: part before '@' if email present, otherwise fallback to id prefix
    String baseUsername = '';
    final email = user.email;
    if (email != null && email.contains('@')) {
      baseUsername = email.split('@').first;
    } else {
      baseUsername = id.replaceAll('-', '').substring(0, 8); // fallback short id
    }

    // normalize username (optional): lowercase and strip spaces
    baseUsername = baseUsername.trim().toLowerCase();

    // ensure unique username in DB
    final username = await ensureUniqueUsername(baseUsername);
    // 4) Display name
    String displayName = username;
    if (provider != 'email' && provider.isNotEmpty) {
      // try multiple likely places for the provider name
      final userMeta = user.userMetadata;
      dynamic raw = userMeta?['raw_user_meta_data'] ?? userMeta;
      displayName =
          (raw is Map)
              ? (raw['name'] ?? raw['full_name'] ?? raw['given_name'] ?? raw['displayName'] ?? raw['username'] ?? username).toString()
              : (userMeta?['name']?.toString() ?? username);
    } // else keep as username

    // 5) Avatar: try common fields (provider picture), otherwise empty string
    String avatarUrl = '';
    final userMeta = user.userMetadata;
    if (userMeta != null) {
      // raw_user_meta_data.picture OR picture OR avatar_url OR avatar
      final raw = userMeta['raw_user_meta_data'] ?? userMeta;
      if (raw is Map) {
        avatarUrl = (raw['picture'] ?? raw['avatar_url'] ?? raw['avatar'] ?? raw['image'])?.toString() ?? '';
      }
      avatarUrl = avatarUrl.isEmpty ? (userMeta['picture'] ?? userMeta['avatar_url'] ?? userMeta['avatar'])?.toString() ?? '' : avatarUrl;
    }

    // 6) Insert into DB
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
      // initialize change timestamps so user can change immediately if you want:
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
      // Avoid infinite loop; but practically will finish quickly
      if (suffix > 1000) {
        // fallback to random suffix
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
  //<editor-fold desc="upload media">
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
    final thumbPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 512, // giảm kích thước
      quality: 75,
    );

    if (thumbPath == null) return null;

    // upload thumbnail file lên Supabase Storage
    final thumbFile = File(thumbPath);
    final thumbUrl = await uploadFile(bucketName: bucketName, file: thumbFile, userId: userId, folder: 'thumbnails');
    return thumbUrl;
  }

  @override
  Future<void> createPostWithFiles({required String userId, required String caption, required List<File> files}) async {
    if (files.isEmpty) return;

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

    final rpcRes = await supabase.rpc('create_post_with_media', params: {'p_user_id': userId, 'p_caption': caption, 'p_medias': medias});

    if (rpcRes.error != null) {
      throw Exception('Create post failed: ${rpcRes.error!.message}');
    }

    final createdPostId = rpcRes.data;
    print('Post created successfully with ID: $createdPostId');
  }

  //</editor-fold>
}
