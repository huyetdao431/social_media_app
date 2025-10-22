// imports giữ nguyên + thêm
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/screens/reels_screen/reel_item.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/utils/overlay.dart';
import '../../cubit/reel_bloc/reel_bloc.dart';

enum ReelTab { reels, friends }

class ReelsScreen extends StatefulWidget {
  static const String route = 'ReelsScreen';
  const ReelsScreen({super.key});
  @override
  State<ReelsScreen> createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ReelBloc(context.read<Api>()), child: ReelPage());
  }
}

class ReelPage extends StatefulWidget {
  const ReelPage({super.key});
  @override
  State<ReelPage> createState() => ReelPageState();
}

class ReelPageState extends State<ReelPage> {
  late final PageController _pageController;
  int _currentPage = 0;
  final Map<int, bool> _shouldPlay = {};
  ReelTab _selectedTab = ReelTab.reels;

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
    // mặc định load feed reels
    context.read<ReelBloc>().add(GetFeedReelsEvent());
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

  void _selectTab(ReelTab tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);

    // gọi bloc để load data phù hợp với tab
    if (tab == ReelTab.reels) {
      context.read<ReelBloc>().add(GetFeedReelsEvent());
    } else {
      // nếu bạn có event load friends reels -> dùng event đó
      // ví dụ: context.read<ReelBloc>().add(GetFriendsReelsEvent());
      // nếu chưa có, bạn có thể filter trên bloc hoặc reuse event với param
      context.read<ReelBloc>().add(GetFeedReelsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReelBloc, ReelState>(
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.loading) {
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide();
        }
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
                  final reel = reels[index];
                  final shouldPlay = _shouldPlay[index] ?? false;
                  // Lưu ý: đảm bảo reel có trường thumbnail và videoUrl (tên có thể khác)
                  return ReelsItem(key: ValueKey('reel_$index'), reel: reel, shouldPlay: shouldPlay, index: index, onTapTogglePlay: () => _togglePlayAt(index));
                },
              ),

              // Top bar: back + centered tabs Reels / Friends
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(onTap: () => _selectTab(ReelTab.reels), child: _buildTabItem(label: 'Reels', active: _selectedTab == ReelTab.reels)),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () => _selectTab(ReelTab.friends),
                          child: _buildTabItem(label: 'Friends', active: _selectedTab == ReelTab.friends),
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

  Widget _buildTabItem({required String label, required bool active}) {
    return Opacity(
      opacity: active ? 1.0 : 0.7,
      child: Column(mainAxisSize: MainAxisSize.min, children: [Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
    );
  }
}
