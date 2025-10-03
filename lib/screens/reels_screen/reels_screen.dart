import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  static const String route = 'ReelsScreen';
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final List<String> _videoUrls = [
    // Thay bằng URL hoặc asset của bạn
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  ];

  // Map giữ VideoPlayerController cho các chỉ mục đã được khởi tạo
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentPage = 0;

  // Public API: parent can call these to pause/play the current reel when it becomes invisible/visible
  void pause() {
    if (_controllers.containsKey(_currentPage)) _controllers[_currentPage]!.pause();
  }

  Future<void> playCurrent() async {
    if (_controllers.containsKey(_currentPage)) {
      _controllers[_currentPage]!.play();
    } else {
      await _initAndPlayController(_currentPage);
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller cho trang đầu
    _initAndPlayController(0);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initAndPlayController(int index) async {
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));
    _controllers[index] = controller;

    await controller.initialize();
    controller.setLooping(true);

    // Nếu đây là trang hiện tại -> play
    if (mounted && index == _currentPage) {
      controller.play();
      setState(() {});
    }

    // Giữ controller cho reuse; không dispose ngay để chuyển mượt
  }

  void _playAtIndex(int index) async {
    // Tạm dừng controller cũ
    if (_controllers.containsKey(_currentPage)) {
      _controllers[_currentPage]!.pause();
    }

    _currentPage = index;

    // Khởi tạo nếu cần rồi play
    await _initAndPlayController(index);
    _controllers[index]!.play();

    // Tự dọn controller xa: nếu muốn, có thể dispose index cách quá xa để tiết kiệm bộ nhớ
    _cleanupFarControllers();

    setState(() {});
  }

  void _cleanupFarControllers() {
    // Giữ controllers cho current, prev và next; dispose các controller khác
    final keep = {_currentPage, _currentPage - 1, _currentPage + 1};
    final toRemove = <int>[];
    for (final key in _controllers.keys) {
      if (!keep.contains(key)) toRemove.add(key);
    }
    for (final key in toRemove) {
      _controllers[key]!.dispose();
      _controllers.remove(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videoUrls.length,
        onPageChanged: (index) => _playAtIndex(index),
        itemBuilder: (context, index) {
          return ReelsItem(
            key: ValueKey('reel_$index'),
            videoPlayerController: _controllers[index],
            onInitNeeded: () => _initAndPlayController(index),
            index: index,
            onTapTogglePlay: () {
              final c = _controllers[index];
              if (c == null) return;
              if (c.value.isPlaying) {
                c.pause();
              } else {
                c.play();
              }
              setState(() {});
            },
          );
        },
      ),
    );
  }
}

class ReelsItem extends StatefulWidget {
  final VideoPlayerController? videoPlayerController;
  final VoidCallback onInitNeeded;
  final VoidCallback onTapTogglePlay;
  final int index;

  const ReelsItem({
    Key? key,
    required this.videoPlayerController,
    required this.onInitNeeded,
    required this.onTapTogglePlay,
    required this.index,
  }) : super(key: key);

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem> with SingleTickerProviderStateMixin {
  bool _showPlayIcon = false;
  bool _liked = false;
  int _likes = 120 + 10; // mẫu

  // simple heart animation
  late AnimationController _likeAnimController;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // Nếu controller chưa khởi tạo, báo cho parent khởi tạo
    if (widget.videoPlayerController == null) {
      widget.onInitNeeded();
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    setState(() {
      _liked = true;
      _likes += 1;
    });
    _likeAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.videoPlayerController;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video area
        if (controller != null && controller.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          )
        else
        // Placeholder while loading
          const Center(child: CircularProgressIndicator()),

        // Dark gradient to make overlay text readable
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

        // Tap to play/pause + double tap to like
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onTapTogglePlay();
            setState(() => _showPlayIcon = !_showPlayIcon);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => _showPlayIcon = false);
            });
          },
          onDoubleTap: _onDoubleTap,
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showPlayIcon ? 1.0 : 0.0,
              child: const Icon(Icons.play_arrow, size: 80, color: Colors.white70),
            ),
          ),
        ),

        // Bottom-left: caption + user
        Positioned(
          left: 12,
          bottom: 20,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3')),
                  SizedBox(width: 8),
                  Text('@username', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Đây là caption mẫu cho video. Thêm mô tả ở đây.', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              // progress bar (fake) - bạn có thể liên kết với controller.value.position
              if (widget.videoPlayerController != null && widget.videoPlayerController!.value.isInitialized)
                VideoProgressIndicator(widget.videoPlayerController!, allowScrubbing: false),
            ],
          ),
        ),

        // Right column: like, comment, share, more
        Positioned(
          right: 12,
          bottom: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like
              GestureDetector(
                onTap: () {
                  setState(() {
                    _liked = !_liked;
                    _likes += _liked ? 1 : -1;
                  });
                },
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _likeAnimController, curve: Curves.easeOut)),
                      child: Icon(
                        Icons.favorite,
                        size: 40,
                        color: _liked ? Colors.redAccent : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$_likes', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Comment
              Column(
                children: const [
                  Icon(Icons.chat_bubble, size: 36, color: Colors.white),
                  SizedBox(height: 6),
                  Text('256', style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),

              // Share
              Column(
                children: const [
                  Icon(Icons.send, size: 36, color: Colors.white),
                  SizedBox(height: 6),
                  Text('Share', style: TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),

              // Profile small avatar
              const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5')),
            ],
          ),
        ),
      ],
    );
  }
}
