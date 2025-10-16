import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/story.dart';

class StoryScreen extends StatelessWidget {
  static const String route = "StoryScreen";
  final Map<String, List<Story>> stories;
  final String startUserId;
  final int startStoryIndex;

  const StoryScreen({super.key, required this.stories, required this.startUserId, required this.startStoryIndex});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: StoryViewer(storiesMap: stories, startUserId: startUserId, startStoryIndex: startStoryIndex)),
      ),
    );
  }
}

/// Flattened item for navigation
class _StoryItem {
  final String userId;
  final Story story;
  final int indexInUser;
  final int userStoriesCount;

  _StoryItem({required this.userId, required this.story, required this.indexInUser, required this.userStoriesCount});
}

class StoryViewer extends StatefulWidget {
  final Map<String, List<Story>> storiesMap;
  final String? startUserId;
  final int startStoryIndex;

  const StoryViewer({super.key, required this.storiesMap, this.startUserId, this.startStoryIndex = 0});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with TickerProviderStateMixin {
  late final List<String> _userOrder;
  late Map<String, List<Story>> _storiesMap;
  late List<_StoryItem> _flatList;

  int _flatIndex = 0;

  // controller that drives the top progress for the active story
  AnimationController? _progressController;

  // video controller (if current is video)
  VideoPlayerController? _videoController;
  StreamSubscription? _videoInitSub;

  // like state per story id
  final Map<String, bool> _likes = {};

  // paused flag (long press)
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _storiesMap = Map<String, List<Story>>.from(widget.storiesMap);
    _userOrder = _storiesMap.keys.toList();

    // Build flattened list in user-order, each user's stories in their list order.
    _flatList = [];
    for (final uid in _userOrder) {
      final lst = _storiesMap[uid] ?? [];
      for (int i = 0; i < lst.length; i++) {
        _flatList.add(_StoryItem(userId: uid, story: lst[i], indexInUser: i, userStoriesCount: lst.length));
      }
    }

    // If startUserId provided, find index
    if (widget.startUserId != null) {
      final startUid = widget.startUserId!;
      final startIdx = _flatList.indexWhere((it) => it.userId == startUid && it.indexInUser == widget.startStoryIndex);
      if (startIdx != -1) _flatIndex = startIdx;
    } else {
      _flatIndex = 0;
    }

    _prepareAndStartCurrent();
  }

  @override
  void dispose() {
    _disposeProgressController();
    _disposeVideoController();
    _videoInitSub?.cancel();
    super.dispose();
  }

  void _disposeProgressController() {
    _progressController?.stop();
    _progressController?.dispose();
    _progressController = null;
  }

  void _disposeVideoController() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
  }

  _StoryItem? get _currentItem => (_flatIndex >= 0 && _flatIndex < _flatList.length) ? _flatList[_flatIndex] : null;

  void _prepareAndStartCurrent() {
    final current = _currentItem;
    if (current == null) {
      Navigator.of(context).pop();
      return;
    }

    // mark viewed locally (you can emit bloc event here to update server/state)
    try {
      current.story.copyWith(isViewed: true); // assuming model allows mutation; else do via bloc
    } catch (_) {}

    // dispose previous controllers
    _disposeProgressController();
    _disposeVideoController();

    // create appropriate controller based on story type
    final isVideo = _isStoryVideo(current.story);

    final double durationSeconds = _getStoryDurationSeconds(current.story);

    _progressController = AnimationController(vsync: this, duration: Duration(milliseconds: (durationSeconds * 1000).toInt()));

    _progressController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onNext();
      }
    });

    // if video: init video controller and when ready start both video and progress
    if (isVideo) {
      final url = current.story.mediaUrl;
      if (url == null || url.isEmpty) {
        _progressController!.forward();
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        _videoController!.setVolume(1.0);
        _videoController!
            .initialize()
            .then((_) {
              if (!mounted) return;
              if ((current.story.duration == null || current.story.duration == 0)) {
                final vd = _videoController!.value.duration;
                final dsec = vd.inMilliseconds / 1000.0;
                final bool wasPaused = _isPaused;
                _disposeProgressController();
                _progressController = AnimationController(vsync: this, duration: Duration(milliseconds: (dsec * 1000).toInt()))..addStatusListener((status) {
                  if (status == AnimationStatus.completed) _onNext();
                });
                if (!wasPaused) {
                  _videoController!.play();
                  _progressController!.forward();
                }
              } else {
                if (!_isPaused) {
                  _videoController!.play();
                  _progressController!.forward();
                }
              }
              setState(() {});
            })
            .catchError((e) {
              if (!_isPaused) _progressController!.forward();
            });
      }
    } else {
      if (!_isPaused) _progressController!.forward();
    }

    setState(() {});
  }

  bool _isStoryVideo(Story s) {
    final type = (s.mediaType ?? '').toLowerCase();
    if (type == 'video') return true;
    final url = s.mediaUrl!;
    if (url.endsWith('.mp4') || url.endsWith('.mov') || url.contains('video')) return true;
    return false;
  }

  double _getStoryDurationSeconds(Story s) {
    if (s.duration != null && s.duration! > 0) return s.duration!.toDouble();
    if (_isStoryVideo(s)) {
      return 1.0;
    }
    return 5.0;
  }

  void _onNext() {
    if (_flatIndex < _flatList.length - 1) {
      setState(() {
        _flatIndex++;
      });
      _prepareAndStartCurrent();
    } else {
      // end of all stories -> close
      Navigator.of(context).pop();
    }
  }

  void _onPrevious() {
    if (_flatIndex > 0) {
      setState(() {
        _flatIndex--;
      });
      _prepareAndStartCurrent();
    } else {
      // at first item: maybe close or do nothing
      Navigator.of(context).pop();
    }
  }

  void _togglePause() {
    final isNowPaused = !_isPaused;
    setState(() {
      _isPaused = isNowPaused;
    });
    if (_progressController != null) {
      if (_isPaused) {
        _progressController!.stop();
      } else {
        _progressController!.forward();
      }
    }
    if (_videoController != null) {
      if (_isPaused) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
  }

  void _toggleLikeForCurrent() {
    final cur = _currentItem;
    if (cur == null) return;
    final id = cur.story.id;
    final currently = _likes[id] ?? false;
    setState(() => _likes[id] = !currently);
    // TODO: call API / dispatch event to persist like
  }

  Widget _buildTopProgress() {
    final cur = _currentItem;
    if (cur == null) return const SizedBox.shrink();

    final userStories = _storiesMap[cur.userId] ?? [];
    final count = userStories.length;
    final currentIndex = cur.indexInUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(count, (i) {
          double value;
          if (i < currentIndex) {
            value = 1.0;
          } else if (i > currentIndex) {
            value = 0.0;
          } else {
            value = (_progressController?.value ?? 0.0).clamp(0.0, 1.0);
          }
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(4)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    final cur = _currentItem;
    if (cur == null) return const SizedBox.shrink();

    final Story s = cur.story;

    String timeText = '';
    try {
      if (s.createdAt != null) {
        final diff = DateTime.now().difference(s.createdAt!);
        if (diff.inSeconds < 60) {
          timeText = '${diff.inSeconds}s';
        } else if (diff.inMinutes < 60) {
          timeText = '${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeText = '${diff.inHours}h';
        } else {
          timeText = '${diff.inDays}d';
        }
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: s.avatarUrl!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[700], width: 40, height: 40),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[700], width: 40, height: 40, child: const Icon(Icons.person)),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.username ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(timeText, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(186))),
            ],
          ),
          const Spacer(),
          if (s.visibility == 'close_friends')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF32D74B), Color(0xFF34C759)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 6),
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close, size: 24)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final cur = _currentItem;
    if (cur == null) return const SizedBox.shrink();
    final s = cur.story;

    if (_isStoryVideo(s)) {
      final vc = _videoController;
      if (vc == null || !(vc.value.isInitialized)) {
        final thumb = s.thumbUrl!;
        return Center(child: thumb.isNotEmpty ? CachedNetworkImage(imageUrl: thumb, fit: BoxFit.contain) : const CircularProgressIndicator());
      } else {
        return Center(child: AspectRatio(aspectRatio: vc.value.aspectRatio, child: VideoPlayer(vc)));
      }
    } else {
      return Center(
        child: CachedNetworkImage(imageUrl: s.mediaUrl!, fit: BoxFit.contain, progressIndicatorBuilder: (_, __, progress) => const CircularProgressIndicator()),
      );
    }
  }

  Widget _buildBottomActions() {
    final cur = _currentItem;
    if (cur == null) return const SizedBox.shrink();
    final id = cur.story.id;
    final liked = _likes[id] ?? false;

    return Positioned(
      right: 12,
      bottom: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              _toggleLikeForCurrent();
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child:
                  liked
                      ? const Icon(Icons.favorite, key: ValueKey('liked'), color: Colors.red, size: 38)
                      : const Icon(Icons.favorite_border, key: ValueKey('unliked'), size: 38),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // TODO: share logic
            },
            child: const Icon(Icons.share, size: 30),
          ),
        ],
      ),
    );
  }

  void _onTapDown(TapDownDetails details, BoxConstraints box) {
    final dx = details.globalPosition.dx;
    final width = box.maxWidth;
    final relative = dx / width;
    if (relative > 0.66) {
      _progressController?.stop();
      _onNext();
    } else if (relative < 0.33) {
      _progressController?.stop();
      _onPrevious();
    } else {
      _togglePause();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final cur = _currentItem;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        if (!_isPaused) _togglePause();
      },
      onLongPressUp: () {
        if (_isPaused) _togglePause();
      },
      child: LayoutBuilder(
        builder: (context, box) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildContent(),

              // tap zones
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => _onTapDown(details, box),
                  // onTapUp: (_) {},
                  // onDoubleTap: ... (optional)
                  child: Container(color: Colors.transparent),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progressController ?? kAlwaysCompleteAnimation,
                      builder: (context, _) {
                        return _buildTopProgress();
                      },
                    ),
                    _buildHeader(),
                  ],
                ),
              ),

              _buildBottomActions(),
            ],
          );
        },
      ),
    );
  }
}

final Animation<double> kAlwaysCompleteAnimation = _AlwaysCompleteAnimation();

class _AlwaysCompleteAnimation extends Animation<double> with AnimationWithParentMixin<double> {
  @override
  Animation<double> get parent => kAlwaysCompleteAnimation; // not used

  @override
  void addListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  void didRegisterListener() {}

  void didUnregisterListener() {}

  void dispose() {}

  @override
  double get value => 1.0;

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}
}
