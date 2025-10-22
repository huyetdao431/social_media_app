import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_media_app/utils/show_comment_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../commons/widgets/display_video.dart';
import '../../models/reel.dart';
import 'package:video_player/video_player.dart';

class ReelsItem extends StatefulWidget {
  final Reel reel;
  final bool shouldPlay;
  final VoidCallback onTapTogglePlay;
  final int index;

  const ReelsItem({
    super.key,
    required this.reel,
    required this.shouldPlay,
    required this.onTapTogglePlay,
    required this.index,
  });

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> with SingleTickerProviderStateMixin {
  bool _showPlayIcon = false;
  bool _liked = false;
  bool _showHeart = false;
  int _likes = 130;
  late AnimationController _heartController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  Alignment _heartAlignment = Alignment.center;
  VideoPlayerController? _innerCtrl;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.95).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_heartController);
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _heartController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _innerCtrl = null;
    _heartController.dispose();
    super.dispose();
  }

  void _onDoubleTap(Offset localPosition, Size boxSize) {
    final dx = (localPosition.dx / boxSize.width).clamp(0.0, 1.0);
    final dy = (localPosition.dy / boxSize.height).clamp(0.0, 1.0);
    setState(() {
      _showHeart = true;
      _heartAlignment = Alignment((dx - 0.5) * 2, (dy - 0.5) * 2);
    });
    _heartController.reset();
    _heartController.forward();
    setState(() {
      _likes += _liked ? 0 : 1;
      _liked = true;
    });
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _showHeart = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SmartVideo(
            url: widget.reel.mediaUrl,
            shouldPlay: widget.shouldPlay,
            showProgress: false,
            allowScrubbing: false,
            onInitialized: (ctrl) {
              if (mounted) setState(() => _innerCtrl = ctrl);
            },
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
              stops: [0.6, 1.0],
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onTapTogglePlay();
            setState(() => _showPlayIcon = !_showPlayIcon);
            Future.delayed(const Duration(milliseconds: 450), () {
              if (mounted) setState(() => _showPlayIcon = false);
            });
          },
          onDoubleTapDown: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final local = renderBox.globalToLocal(details.globalPosition);
            _onDoubleTap(local, renderBox.size);
          },
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showPlayIcon ? 1.0 : 0.0,
              child: const Icon(Icons.play_arrow, size: 80, color: Colors.white70),
            ),
          ),
        ),
        if (_showHeart)
          IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: _heartController,
              builder: (context, child) {
                return Align(
                  alignment: _heartAlignment,
                  child: Opacity(
                    opacity: _opacityAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: const Icon(Icons.favorite, size: 120, color: Colors.red, shadows: [Shadow(blurRadius: 12, color: Colors.black54)]),
                    ),
                  ),
                );
              },
            ),
          ),
        Positioned(
          left: 0,
          bottom: 0,
          right: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.reel.avatarUrl ?? '',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey[300], width: 44, height: 44),
                        errorWidget: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 32)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.reel.userName ?? '@username', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(widget.reel.caption, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _liked = !_liked;
                    _likes += _liked ? 1 : -1;
                  });
                },
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: _liked
                          ? const Icon(Icons.favorite, key: ValueKey('liked'), color: Colors.red, size: 40)
                          : const Icon(Icons.favorite, key: ValueKey('unliked'), color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 6),
                    Text('$_likes', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  GestureDetector(onTap: () => showCommentsModal(context, targetType: 'post', targetId: widget.reel.reelId), child: const Icon(Icons.chat_bubble, size: 36, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('256', style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),
              Column(
                children: const [
                  Icon(Icons.send, size: 36, color: Colors.white),
                  SizedBox(height: 6),
                  Text('Share', style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),
              const Icon(Icons.more_vert, size: 36, color: Colors.white),
              const SizedBox(height: 18),
            ],
          ),
        ),
        if (_innerCtrl != null && _innerCtrl!.value.isInitialized)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45, // nền mờ để progress hiện rõ
                borderRadius: BorderRadius.circular(6),
              ),
              child: SizedBox(
                height: 8,
                child: VideoProgressIndicator(
                  _innerCtrl!,
                  allowScrubbing: false,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white38,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
