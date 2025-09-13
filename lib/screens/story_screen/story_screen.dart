import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryScreen extends StatelessWidget {
  static const String route = "StoryScreen";

  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: const Scaffold(
        body: Page(),
      ),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  int currentIndex = 0;
  int previousIndex = 0;

  List<Widget> stories = [
    Center(
        child: Image.asset(
          'assets/images/avt_01.png',
          fit: BoxFit.cover,
        )),
    Video(asset: 'assets/videos/ntht_01.mp4', shouldPlay: true),
    Center(
        child: Image.asset(
          'assets/images/avt_03.png',
          fit: BoxFit.cover,
        )),
    Video(asset: 'assets/videos/ntht_02.mp4', shouldPlay: true),
    Center(
        child: Image.asset(
          'assets/images/avt_05.png',
          fit: BoxFit.cover,
        )),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
            onPanDown: (details) {
              if (currentIndex == stories.length - 1) {
                Navigator.of(context).pop();
                return;
              }
              setState(() {
                double mid = MediaQuery.sizeOf(context).width / 2;
                previousIndex = currentIndex;
                if (details.globalPosition.dx > mid) {
                  currentIndex += currentIndex == stories.length ? 0 : 1;
                } else {
                  currentIndex -= currentIndex == 0 ? 0 : 1;
                }
              });
            },
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final inAnimation = Tween<Offset>(
                    begin: currentIndex > previousIndex ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);

                  final outAnimation = Tween<Offset>(
                    begin: currentIndex > previousIndex ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);

                  if (child.key == ValueKey(currentIndex)) {
                    return SlideTransition(
                      position: inAnimation,
                      child: child,
                    );
                  } else {
                    return SlideTransition(
                      position: outAnimation,
                      child: child,
                    );
                  }
                },
                child: Container(key: ValueKey(currentIndex), child: stories[currentIndex]))),
        UserLabel(),
        Positioned(
          top: 0,
          left: 0,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              children: [
                for (int i = 0; i < stories.length; i++)
                  Expanded(
                      child: SmoothProgressBar(
                        key: ValueKey(i == currentIndex),
                        isPlay: i == currentIndex,
                        onCompleted: () {
                          if (currentIndex < stories.length - 1) {
                            setState(() => currentIndex++);
                          } else {
                            Navigator.of(context).pop(); // hết story thì thoát
                          }
                        },
                      )),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class SmoothProgressBar extends StatefulWidget {
  const SmoothProgressBar({
    super.key,
    required this.isPlay,
    this.onCompleted,
  });

  final bool isPlay;
  final VoidCallback? onCompleted;

  @override
  State<SmoothProgressBar> createState() => _SmoothProgressBarState();
}

class _SmoothProgressBarState extends State<SmoothProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.isPlay) {
        widget.onCompleted?.call();
      }
    });

    if (widget.isPlay) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SmoothProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlay && !_controller.isAnimating) {
      _controller.forward(from: 0);
    } else if (!widget.isPlay && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // ngắt hẳn animation khi thoát
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
          ),
          clipBehavior: Clip.hardEdge,
          child: LinearProgressIndicator(
            value: _controller.value,
            minHeight: 4,
            backgroundColor: Colors.grey.withAlpha(90),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(164)),
          ),
        );
      },
    );
  }
}

class UserLabel extends StatefulWidget {
  const UserLabel({super.key});

  @override
  State<UserLabel> createState() => _UserLabelState();
}

class _UserLabelState extends State<UserLabel> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 36,
        left: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            height: 36,
            width: MediaQuery.sizeOf(context).width - 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text('username'),
                    const SizedBox(
                      width: 8,
                    ),
                    Text('upload time'),
                  ],
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
              ],
            ),
          ),
        ));
  }
}

class Video extends StatefulWidget {
  final String asset;
  final bool shouldPlay; // điều kiện phát video
  final double aspectRatio;

  const Video({super.key, required this.asset, required this.shouldPlay, this.aspectRatio = 1});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> with RouteAware {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(widget.asset)
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
    if (oldWidget.asset != widget.asset) {
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
    if (_controller != null && _controller!.value.isInitialized) {
      return SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
