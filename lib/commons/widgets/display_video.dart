import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  final File video;
  final bool shouldPlay; // điều kiện phát video
  final double aspectRatio;

  const Video({super.key, required this.video, required this.shouldPlay, this.aspectRatio = 1});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> with RouteAware{
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.file(widget.video)
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          if (widget.shouldPlay) {
            _controller!.play();
          }
        }
      });
  }

  @override
  void didUpdateWidget(covariant Video oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nếu file thay đổi → khởi tạo lại
    if (oldWidget.video.path != widget.video.path) {
      _controller?.dispose();
      _controller = null;
      _initVideo();
    } else if (oldWidget.shouldPlay != widget.shouldPlay) {
      // Khi điều kiện phát thay đổi
      if (widget.shouldPlay) {
        _controller?.play();
      } else {
        _controller?.pause();
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
    var screenWid = MediaQuery.sizeOf(context).height;
    if (_controller != null && _controller!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: screenWid * 0.35,
          height: screenWid * 0.35,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: screenWid * 0.3,
      height: screenWid * 0.3,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}