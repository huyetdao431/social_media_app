import 'dart:io';
import 'package:video_player/video_player.dart';

Future<int> getVideoDuration(String path) async {
  final controller = VideoPlayerController.file(File(path));
  await controller.initialize();
  final duration = controller.value.duration;
  await controller.dispose();
  return duration.inSeconds;
}
