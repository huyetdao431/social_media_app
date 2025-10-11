import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class SmartVideo extends StatefulWidget {
  final File? file;
  final String? url; // Nếu có url thì ưu tiên url
  final bool shouldPlay;
  final double? aspectRatio; // optional override

  const SmartVideo({
    super.key,
    this.file,
    this.url,
    required this.shouldPlay,
    this.aspectRatio,
  }) : assert(file != null || url != null, 'Provide either file or url');

  @override
  State<SmartVideo> createState() => _SmartVideoState();
}

class _SmartVideoState extends State<SmartVideo> {
  VideoPlayerController? _controller;

  CachedVideoPlayerPlus? _cachedPlayer;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _disposeCurrentController() {
    _controller?.dispose();
    _controller = null;
    _cachedPlayer?.dispose();
    _cachedPlayer = null;
    _initialized = false;
  }

  Future<void> _setupController() async {
    _disposeCurrentController();

    try {
      if (widget.url != null) {
        final player = CachedVideoPlayerPlus.networkUrl(
          Uri.parse(widget.url!),
          invalidateCacheIfOlderThan: const Duration(minutes: 10),
          // cacheKey: 'video-id-for-${widget.url}',
        );
        await player.initialize();
        _cachedPlayer = player;
        _controller = player.controller;
      } else if (widget.file != null) {
        _controller = VideoPlayerController.file(widget.file!);
        await _controller!.initialize();
      }

      if (_controller == null) return;

      _controller!.setLooping(true);

      if (!mounted) return;
      setState(() {
        _initialized = true;
      });

      if (widget.shouldPlay) _controller!.play();
    } catch (e) {
      if (!mounted) return;
      debugPrint('SmartVideo Error: $e');
      setState(() {
        _initialized = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant SmartVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldSrc = oldWidget.url ?? oldWidget.file?.path;
    final newSrc = widget.url ?? widget.file?.path;

    // Nếu đổi source (URL/File) thì khởi tạo lại controller
    if (oldSrc != newSrc) {
      _setupController();
      return;
    }

    // Nếu chỉ thay đổi play state và đã khởi tạo xong
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
    _disposeCurrentController(); // Dùng hàm dispose đã tạo để đảm bảo dọn dẹp
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      // Placeholder kích thước vuông theo width khi đang tải
      final width = MediaQuery.sizeOf(context).width;
      final size = width;
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: CircularProgressIndicator.adaptive(), // Dùng adaptive cho cross-platform
        ),
      );
    }

    // Lấy kích thước và tỉ lệ của video từ controller
    final videoSize = _controller!.value.size;
    final defaultAspect = videoSize.width > 0 && videoSize.height > 0
        ? videoSize.width / videoSize.height
        : 1.0;

    final aspect = widget.aspectRatio ?? defaultAspect;

    return AspectRatio(
      aspectRatio: aspect,
      child: FittedBox(
        fit: BoxFit.cover,
        // Khi dùng FittedBox(fit: BoxFit.cover), chúng ta cần đảm bảo
        // kích thước của SizedBox là kích thước thực của video.
        // Điều này giúp VideoPlayer hiển thị đúng nội dung.
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(_controller!), // Luôn dùng _controller!
        ),
      ),
    );
  }
}
