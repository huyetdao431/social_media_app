import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

class Helper {
  static Future<void> saveImageToGallery(File imageFile) async {
    await PhotoManager.editor.saveImageWithPath(
      imageFile.path,
      title: "edited_${DateTime.now().millisecondsSinceEpoch}.png",
      relativePath: 'social_media_app',
    );
  }

  static Future<void> saveVideoToGallery(File videoFile) async {
    await PhotoManager.editor.saveVideo(
      videoFile,
      title: "edited_${DateTime.now().millisecondsSinceEpoch}.mp4",
      relativePath: 'social_media_app',
    );
  }
}
