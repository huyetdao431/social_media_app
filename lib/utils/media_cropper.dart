import 'dart:io';
import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class MediaCropper {
  static Future<File> cropImage({required File inputFile, required double aspectRatio, bool overwrite = false}) async {
    final Uint8List bytes = await inputFile.readAsBytes();

    final img.Image? original = img.decodeImage(bytes);
    if (original == null) throw Exception('Không đọc được ảnh');

    late img.Image cropped;

    final double originalRatio = original.width / original.height;
    if (originalRatio > aspectRatio) {
      int newWidth = (original.height * aspectRatio).floor();
      int x = (original.width - newWidth) ~/ 2;
      cropped = img.copyCrop(original, x: x, y: 0, width: newWidth, height: original.height);
    } else {
      int newHeight = (original.width / aspectRatio).floor();
      int y = (original.height - newHeight) ~/ 2;
      cropped = img.copyCrop(original, x: 0, y: y, width: original.width, height: newHeight);
    }

    final Uint8List croppedBytes = Uint8List.fromList(img.encodeJpg(cropped, quality: 90));

    File outputFile;
    if (overwrite) {
      outputFile = inputFile;
    } else {
      final dir = inputFile.parent;
      final name = p.basenameWithoutExtension(inputFile.path);
      final ext = p.extension(inputFile.path);
      outputFile = File(p.join(dir.path, '${name}_cropped$ext'));
    }

    await outputFile.writeAsBytes(croppedBytes);

    return outputFile;
  }

  static Future<File> cropVideo({required File inputFile, required double aspectRatio, bool overwrite = false}) async {
    final probeSession = await FFmpegKit.executeWithArguments([
      '-v',
      'error',
      '-select_streams',
      'v:0',
      '-show_entries',
      'stream=width,height',
      '-of',
      'csv=s=x:p=0',
      '-i',
      inputFile.path,
    ]);
    final info = await probeSession.getOutput();
    if (info == null || info.isEmpty) throw Exception('Không lấy được kích thước video');
    final parts = info.trim().split('x');
    final width = int.parse(parts[0]);
    final height = int.parse(parts[1]);

    int cropW = width;
    int cropH = height;
    int x = 0, y = 0;
    double currentRatio = width / height;

    if (currentRatio > aspectRatio) {
      cropW = (height * aspectRatio).floor();
      x = ((width - cropW) / 2).floor();
    } else {
      cropH = (width / aspectRatio).floor();
      y = ((height - cropH) / 2).floor();
    }

    final dir = inputFile.parent;
    final name = p.basenameWithoutExtension(inputFile.path);
    final ext = p.extension(inputFile.path);
    final outputPath = overwrite ? inputFile.path : p.join(dir.path, '${name}_cropped$ext');

    final cropFilter = 'crop=${cropW}:${cropH}:${x}:${y}';
    final ffmpegCmd = ['-i', inputFile.path, '-filter:v', cropFilter, '-c:a', 'copy', outputPath];

    final session = await FFmpegKit.executeWithArguments(ffmpegCmd);
    final returnCode = await session.getReturnCode();
    if (returnCode == null || !returnCode.isValueSuccess()) {
      throw Exception('Crop video thất bại: ${await session.getOutput()}');
    }

    return File(outputPath);
  }
}
