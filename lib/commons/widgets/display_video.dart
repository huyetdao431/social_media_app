import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SmartVideo extends StatefulWidget {
  final File? file;
  final String? url; // nếu có url thì ưu tiên url
  final bool shouldPlay;
  final double? aspectRatio; // optional override

  const SmartVideo({super.key, this.file, this.url, required this.shouldPlay, this.aspectRatio})
    : assert(file != null || url != null, 'Provide either file or url');

  @override
  State<SmartVideo> createState() => _SmartVideoState();
}

class _SmartVideoState extends State<SmartVideo> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  Future<void> _setupController() async {
    try {
      if (widget.url != null) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      } else if (widget.file != null) {
        _controller = VideoPlayerController.file(widget.file!);
      }
      if (_controller == null) return;

      _controller!.setLooping(true);

      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _initialized = true;
      });
      if (widget.shouldPlay) _controller!.play();
    } catch (e) {
      // handle init error if needed
    }
  }

  @override
  void didUpdateWidget(covariant SmartVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // nếu đổi source thì rebuild controller
    final oldSrc = oldWidget.url ?? oldWidget.file?.path;
    final newSrc = widget.url ?? widget.file?.path;
    if (oldSrc != newSrc) {
      _controller?.dispose();
      _controller = null;
      _initialized = false;
      _setupController();
      return;
    }

    // nếu thay đổi play state
    if (oldWidget.shouldPlay != widget.shouldPlay && _controller != null && _initialized) {
      if (widget.shouldPlay) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      // placeholder kích thước vuông theo width
      final width = MediaQuery.sizeOf(context).width;
      final size = width;
      return SizedBox(width: size, height: size, child: const Center(child: CircularProgressIndicator()));
    }

    final videoSize = _controller!.value.size;
    final aspect = widget.aspectRatio ?? (videoSize.width > 0 ? videoSize.width / videoSize.height : 1.0);

    return AspectRatio(
      aspectRatio: aspect,
      child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!))),
    );
  }
}
