import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/profile_cubit/profile_cubit.dart';
import '../reels_screen/reel_item.dart';

class ListProfileReelScreen extends StatefulWidget {
  static const String route = 'ListProfileReelScreen';
  final int index;

  const ListProfileReelScreen({super.key, required this.index});

  @override
  State<ListProfileReelScreen> createState() => _ListProfileReelScreenState();
}

class _ListProfileReelScreenState extends State<ListProfileReelScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  // map index -> shouldPlay
  final Map<int, bool> _shouldPlay = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.index;
    _pageController = PageController(initialPage: widget.index);

    // ban đầu chỉ play page được yêu cầu
    _shouldPlay[widget.index] = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      // tắt tất cả, bật page hiện tại
      _shouldPlay.clear();
      _shouldPlay[index] = true;
    });
  }

  void _togglePlayAt(int index) {
    setState(() {
      final v = _shouldPlay[index] ?? false;
      _shouldPlay[index] = !v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final reels = cubit.state.userReels;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: reels.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final reel = reels[index];
                  final shouldPlay = _shouldPlay[index] ?? false;

                  return ReelsItem(
                    key: ValueKey(reel.reelId),
                    reel: reel,
                    shouldPlay: shouldPlay,
                    index: index,
                    onTapTogglePlay: () => _togglePlayAt(index),
                  );
                },
              ),

              // Top bar: back + centered "Reels"
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text('Reels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
