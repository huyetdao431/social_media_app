import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import '../../commons/widgets/stickers_gridview.dart';
import '../../cubit/post_cubit/post_cubit.dart';

class EditVideoScreen extends StatelessWidget {
  static const String route = 'EditVideoScreen';

  const EditVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: Page());
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  String? videoPath;

  ProVideoController? _proVideoController;
  late VideoPlayerController _videoController;
  late VideoMetadata _videoMetadata;

  final _editorKey = GlobalKey<ProImageEditorState>();
  final _outputFormat = VideoOutputFormat.mp4;
  final _taskId = DateTime.now().microsecondsSinceEpoch.toString();
  String? _outputPath;

  final _videoConfigs = VideoEditorConfigs(
    initialMuted: false,
    initialPlay: true,
    isAudioSupported: true,
    style: const VideoEditorStyle(trimBarHeight: 0, trimDurationBackground: Colors.transparent, trimDurationTextColor: Colors.transparent),
    controlsPosition: VideoEditorControlPosition.bottom,
    widgets: VideoEditorWidgets(trimBar: SizedBox.shrink(), trimDurationInfo: null, infoBanner: null, trimBarSkeletonLoader: SizedBox.shrink()),
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    videoPath = await context.read<PostCubit>().loadVideo();
    if (videoPath == null) return;

    _videoMetadata = await ProVideoEditor.instance.getMetadata(EditorVideo.file(File(videoPath!)));

    _videoController = VideoPlayerController.file(File(videoPath!));
    await _videoController.initialize();

    // set âm lượng ban đầu
    await _videoController.setVolume(1);

    // set trạng thái play/pause ban đầu
    await _videoController.play();

    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: _videoMetadata.resolution,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoController.dispose();
    _proVideoController?.dispose();
    super.dispose();
  }

  Future<void> _generateVideo(CompleteParameters parameters) async {
    final targetAspectRatio = context.read<PostCubit>().state.aspectRatio;
    final videoW = _videoMetadata.resolution.width;
    final videoH = _videoMetadata.resolution.height;

    ExportTransform? transform;

    if (parameters.isTransformed) {
      // User đã crop
      transform = ExportTransform(
        width: parameters.cropWidth,
        height: parameters.cropHeight,
        rotateTurns: parameters.rotateTurns,
        x: parameters.cropX,
        y: parameters.cropY,
        flipX: parameters.flipX,
        flipY: parameters.flipY,
      );
    } else {
      // Auto crop theo aspectRatio của cubit
      transform = _autoCropTransform(videoW.floor(), videoH.floor(), targetAspectRatio);
    }

    final exportModel = RenderVideoModel(
      id: _taskId,
      video: EditorVideo.file(File(videoPath!)),
      outputFormat: _outputFormat,
      enableAudio: _proVideoController?.isAudioEnabled ?? true,
      imageBytes: parameters.layers.isNotEmpty ? parameters.image : null,
      blur: parameters.blur,
      colorMatrixList: parameters.colorFilters,
      startTime: parameters.startTime,
      endTime: parameters.endTime,
      transform: transform,
    );

    final directory = await getTemporaryDirectory();
    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile('${directory.path}/edited_video_$now.mp4', exportModel);

    await saveVideo(_outputPath!);
  }

  ExportTransform _autoCropTransform(int videoW, int videoH, double targetAspectRatio) {
    final currentRatio = videoW / videoH;

    int cropW, cropH, offsetX, offsetY;
    if (currentRatio > targetAspectRatio) {
      // Video quá rộng => crop ngang
      cropH = videoH;
      cropW = (videoH * targetAspectRatio).toInt();
      offsetX = ((videoW - cropW) / 2).toInt();
      offsetY = 0;
    } else {
      // Video quá cao => crop dọc
      cropW = videoW;
      cropH = (videoW / targetAspectRatio).toInt();
      offsetX = 0;
      offsetY = ((videoH - cropH) / 2).toInt();
    }

    return ExportTransform(width: cropW, height: cropH, x: offsetX, y: offsetY, rotateTurns: 0, flipX: false, flipY: false);
  }

  Future<void> saveVideo(String videoPath) async {
    await context.read<PostCubit>().saveVideo(videoPath);
  }

  void _onCloseEditor(EditorMode editorMode) {
    if (editorMode != EditorMode.main) {
      Navigator.pop(context);
      return;
    }
    if (_outputPath != null) {
      Navigator.pop(context, _outputPath); // Trả path video đã chỉnh sửa
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildVideoPlayer() {
    return Center(child: VideoPlayer(_videoController));
  }

  @override
  Widget build(BuildContext context) {
    if (videoPath == null || _proVideoController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return Scaffold(
          body: Stack(
            children: [
              ProImageEditor.video(
                _proVideoController!,
                key: _editorKey,
                callbacks: ProImageEditorCallbacks(
                  onCompleteWithParameters: _generateVideo,
                  onCloseEditor: _onCloseEditor,
                  videoEditorCallbacks: VideoEditorCallbacks(
                    onPause: _videoController.pause,
                    onPlay: _videoController.play,
                    onMuteToggle: (isMuted) {
                      _videoController.setVolume(isMuted ? 0 : 100);
                    },
                    onTrimSpanUpdate: (TrimDurationSpan span) async {
                      // Khi user kéo thanh trim, nhảy tới vị trí bắt đầu
                      await _videoController.pause();
                      await _videoController.seekTo(span.start);
                    },
                    onTrimSpanEnd: (TrimDurationSpan span) async {
                      // Sau khi user thả trim handle, bắt đầu phát lại từ điểm start
                      await _videoController.seekTo(span.start);
                      await _videoController.play();
                    },
                  ),
                ),
                configs: ProImageEditorConfigs(
                  mainEditor: MainEditorConfigs(
                    tools: [
                      SubEditorMode.text,
                      SubEditorMode.paint,
                      SubEditorMode.cropRotate,
                      SubEditorMode.filter,
                      SubEditorMode.sticker,
                      SubEditorMode.emoji,
                      SubEditorMode.tune,
                    ],
                  ),
                  stickerEditor: StickerEditorConfigs(
                    builder: (addSticker, scrollController) {
                      return StickerMediaGrid(addSticker: addSticker, controller: scrollController);
                    },
                  ),
                  videoEditor: _videoConfigs,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
