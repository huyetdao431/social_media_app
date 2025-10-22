import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

import '../../cubit/reel_bloc/reel_bloc.dart';

class ReelsScreen extends StatefulWidget {
  static const String route = 'ReelsScreen';

  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen> {
  late final PageController _pageController;

  int _currentPage = 0;

  final Map<int, bool> _shouldPlay = {};

  void pause() {
    setState(() {
      _shouldPlay[_currentPage] = false;
    });
  }

  Future<void> playCurrent() async {
    setState(() {
      _shouldPlay[_currentPage] = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage);

    _shouldPlay.clear();
    _shouldPlay[_currentPage] = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index == _currentPage) return;

    setState(() {
      _shouldPlay[_currentPage] = false;

      _currentPage = index;

      _shouldPlay[_currentPage] = true;

      //preload prev/next
      _shouldPlay[_currentPage - 1] = _shouldPlay[_currentPage - 1] ?? false;
      _shouldPlay[_currentPage + 1] = _shouldPlay[_currentPage + 1] ?? false;
    });
  }

  void _togglePlayAt(int index) {
    setState(() {
      final prev = _shouldPlay[index] ?? false;
      _shouldPlay[index] = !prev;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReelBloc(context.read<Api>()),
      child: BlocConsumer<ReelBloc, ReelState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          var reels = state.currentReels;
          var count = reels.length;
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: count,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final url = reels[index];
                    final shouldPlay = _shouldPlay[index] ?? false;
                    return Container();
                    // return ReelsItem(
                    //   key: ValueKey('reel_$index'),
                    //   videoUrl: url,
                    //   shouldPlay: shouldPlay,
                    //   index: index,
                    //   onTapTogglePlay: () => _togglePlayAt(index),
                    // );
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {}, child: Text('Reels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                          const SizedBox(width: 16,),
                          GestureDetector(
                              onTap: () {}, child: Text('Friends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
