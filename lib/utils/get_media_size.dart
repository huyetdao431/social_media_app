import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:path/path.dart' as p;

Future<({int width, int height})> getMediaSize(File file) async {
  final path = file.path.toLowerCase();

  if (path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.webp') ||
      path.endsWith('.bmp') ||
      path.endsWith('.gif')) {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) throw Exception('Không đọc được ảnh');
      return (width: decoded.width, height: decoded.height);
    } catch (e) {
      throw Exception('Lỗi khi đọc ảnh: $e');
    }
  }

  else if (path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.avi') ||
      path.endsWith('.mkv') ||
      path.endsWith('.webm')) {
    try {
      final session = await FFprobeKit.getMediaInformation(file.path);
      final info = session.getMediaInformation();
      if (info == null) throw Exception('Không đọc được thông tin video');
      final streams = info.getStreams();
      if (streams.isEmpty) throw Exception('Không có stream video');

      final videoStream = streams.firstWhere(
            (s) => s.getType() == 'video',
        orElse: () => throw Exception('Không có video stream'),
      );

      final width = videoStream.getWidth() ?? 0;
      final height = videoStream.getHeight() ?? 0;

      if (width == 0 || height == 0) throw Exception('Không đọc được kích thước video');

      return (width: width, height: height);
    } catch (e) {
      throw Exception('Lỗi khi đọc video: $e');
    }
  }

  else {
    throw Exception('Định dạng file không được hỗ trợ: ${p.extension(file.path)}');
  }
}
