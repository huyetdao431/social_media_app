import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

class GallerySaver {
  static Future<String> saveImageToGallery(File imageFile) async {
    final asset = await PhotoManager.editor.saveImageWithPath(
      imageFile.path,
      title: "edited_${DateTime.now().millisecondsSinceEpoch}.png",
      relativePath: 'social_media_app',
    );
    final file = await asset.file;
    return file!.path;
  }

  static Future<String> saveVideoToGallery(File videoFile) async {
    final asset = await PhotoManager.editor.saveVideo(
      videoFile,
      title: "edited_${DateTime.now().millisecondsSinceEpoch}.mp4",
      relativePath: 'social_media_app',
    );
    final file = await asset.file;
    return file!.path;
  }
}
