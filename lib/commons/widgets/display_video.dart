import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class SmartVideo extends StatefulWidget {
  final File? file;
  final String? url;
  final bool shouldPlay;
  final bool showLoadingIndicator;
  final double? aspectRatio;
  final bool showProgress;
  final bool allowScrubbing;
  final ValueChanged<VideoPlayerController?>? onInitialized;

  const SmartVideo({
    super.key,
    this.file,
    this.url,
    required this.shouldPlay,
    this.showLoadingIndicator = true,
    this.aspectRatio,
    this.showProgress = false,
    this.allowScrubbing = false,
    this.onInitialized,
  }) : assert(file != null || url != null, 'Provide either file or url');

  @override
  State<SmartVideo> createState() => _SmartVideoState();
}

class _SmartVideoState extends State<SmartVideo> {
  VideoPlayerController? _controller;
  CachedVideoPlayerPlus? _cachedPlayer;
  bool _initialized = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _notifyInitialized(VideoPlayerController? ctrl) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onInitialized?.call(ctrl);
    });
  }

  void _disposeCurrentController() {
    if (_cachedPlayer != null) {
      try {
        _cachedPlayer!.dispose();
      } catch (e) {
        debugPrint('Error disposing cached player: $e');
      }
      _cachedPlayer = null;
      _controller = null;
      _notifyInitialized(null);
    } else {
      try {
        _controller?.dispose();
      } catch (e) {
        debugPrint('Error disposing controller: $e');
      }
      _controller = null;
      _notifyInitialized(null);
    }
    _initialized = false;
  }

  Future<void> _setupController() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _disposeCurrentController();
    try {
      if (widget.url != null) {
        final player = CachedVideoPlayerPlus.networkUrl(Uri.parse(widget.url!), invalidateCacheIfOlderThan: const Duration(minutes: 10));
        await player.initialize();
        _cachedPlayer = player;
        _controller = player.controller;
      } else if (widget.file != null) {
        _controller = VideoPlayerController.file(widget.file!);
        await _controller!.initialize();
      }
      if (!mounted) {
        _isInitializing = false;
        return;
      }
      _controller?.setLooping(true);
      setState(() {
        _initialized = _controller?.value.isInitialized ?? false;
      });
      _notifyInitialized(_controller);
      if (widget.shouldPlay && _controller != null && _controller!.value.isInitialized) {
        _controller!.play();
      } else if (_controller != null) {
        _controller!.pause();
      }
    } catch (e) {
      debugPrint('SmartVideo init error: $e');
      if (mounted) setState(() => _initialized = false);
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void didUpdateWidget(covariant SmartVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSrc = oldWidget.url ?? oldWidget.file?.path;
    final newSrc = widget.url ?? widget.file?.path;
    if (oldSrc != newSrc) {
      _setupController();
      return;
    }
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
    _disposeCurrentController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      final width = MediaQuery.sizeOf(context).width;
      final size = width;
      return widget.showLoadingIndicator
          ? SizedBox(width: size, height: size, child: const Center(child: CircularProgressIndicator.adaptive()))
          : const SizedBox.shrink();
    }

    final videoSize = _controller!.value.size;
    final defaultAspect = videoSize.width > 0 && videoSize.height > 0 ? videoSize.width / videoSize.height : 1.0;
    final aspect = widget.aspectRatio ?? defaultAspect;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final calculatedHeight = screenWidth / aspect;

    final videoWidget = FittedBox(fit: BoxFit.cover, child: SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller!)));

    if (widget.aspectRatio != null) {
      return AspectRatio(aspectRatio: aspect, child: Stack(fit: StackFit.expand, children: [videoWidget]));
    }

    return SizedBox(width: screenWidth, height: calculatedHeight, child: Stack(fit: StackFit.expand, children: [videoWidget]));
  }
}
