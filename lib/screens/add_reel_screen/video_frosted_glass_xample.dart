import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

class VideoFrostedGlassExample extends StatefulWidget {
  static const String route = 'VideoFrostedGlassExample';
  const VideoFrostedGlassExample({super.key, required this.fileVideo});
  final File fileVideo;

  @override
  State<VideoFrostedGlassExample> createState() =>
      _VideoFrostedGlassExampleState();
}

class _VideoFrostedGlassExampleState extends State<VideoFrostedGlassExample> {
  late VideoPlayerController _controller;
  double _start = 0.0;
  double _end = 0.0;
  bool _isReady = false;
  bool _isRendering = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // 🔹 Sửa lại: dùng file local thay vì URL
    _controller = VideoPlayerController.file(widget.fileVideo)
      ..initialize().then((_) {
        setState(() {
          _isReady = true;
          _end = _controller.value.duration.inMilliseconds.toDouble();
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  String _msToLabel(double ms) {
    final d = Duration(milliseconds: ms.toInt());
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  Future<String> _renderTrimmedVideo() async {
    setState(() {
      _isRendering = true;
      _progress = 0;
    });

    // 🔹 Sửa lại: EditorVideo.file thay vì network
    final model = RenderVideoModel(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      video: EditorVideo.file(widget.fileVideo),
      startTime: Duration(milliseconds: _start.toInt()),
      endTime: Duration(milliseconds: _end.toInt()),
      enableAudio: true,
      outputFormat: VideoOutputFormat.mp4,
    );

    // Lắng nghe tiến trình (nếu có)
    final progressStream = ProVideoEditor.instance.progressStreamById(model.id);
    final sub = progressStream.listen((p) {
      setState(() {
        _progress = p.progress;
      });
    });

    // renderVideo trả về Uint8List (binary mp4)
    Uint8List bytes = await ProVideoEditor.instance.renderVideo(model);

    // Lưu file
    final dir = await getTemporaryDirectory();
    final outFile = File(
        '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.mp4');
    await outFile.writeAsBytes(bytes);

    await sub.cancel();

    setState(() {
      _isRendering = false;
      _progress = 1.0;
    });

    return outFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Frosted Editor'),
      ),
      body: _isReady
          ? Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 18,
                  child: Card(
                    color: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // TODO: thêm chức năng sticker overlay
                            },
                            icon: const Icon(Icons.emoji_emotions),
                            label: const Text('Stickers'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    'Trim: ${_msToLabel(_start)} - ${_msToLabel(_end)}'),
                                RangeSlider(
                                  min: 0,
                                  max: _controller
                                      .value.duration.inMilliseconds
                                      .toDouble(),
                                  divisions: 100,
                                  values: RangeValues(_start, _end),
                                  onChanged: (v) {
                                    setState(() {
                                      _start = v.start;
                                      _end = v.end;
                                      _controller.seekTo(Duration(
                                          milliseconds:
                                          _start.toInt()));
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _isRendering
                              ? Column(
                            children: [
                              SizedBox(
                                width: 80,
                                child: LinearProgressIndicator(
                                    value: _progress),
                              ),
                              Text(
                                  '${(_progress * 100).toStringAsFixed(0)}%'),
                            ],
                          )
                              : ElevatedButton(
                            onPressed: () async {
                              final outPath =
                              await _renderTrimmedVideo();
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExportPreviewScreen(
                                          filePath: outPath),
                                ),
                              );
                            },
                            child: const Text('Export'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class ExportPreviewScreen extends StatefulWidget {
  const ExportPreviewScreen({super.key, required this.filePath});
  final String filePath;
  @override
  State<ExportPreviewScreen> createState() => _ExportPreviewScreenState();
}

class _ExportPreviewScreenState extends State<ExportPreviewScreen> {
  late VideoPlayerController _p;
  @override
  void initState() {
    super.initState();
    _p = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
        _p.play();
      });
  }

  @override
  void dispose() {
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Preview')),
      body: Center(
        child: _p.value.isInitialized
            ? AspectRatio(
            aspectRatio: _p.value.aspectRatio, child: VideoPlayer(_p))
            : const CircularProgressIndicator(),
      ),
    );
  }
}
