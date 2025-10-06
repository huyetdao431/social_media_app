import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/create_media_screen/create_media_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/reels_screen/reels_screen.dart';
import 'package:social_media_app/screens/search_screen/search_screen.dart';

import '../../cubit/main_cubit/main_cubit.dart';

class MainScreen extends StatefulWidget {
  static const String route = 'MainScreen';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget?> _pages = List.filled(5, null);
  final GlobalKey<ReelsScreenState> _reelsKey = GlobalKey<ReelsScreenState>();
  bool _createMediaOpening = false; // prevent double open

  void onItemTapped(int index) {
    // Prevent double open for middle button
    if (index == 2) {
      Navigator.of(context).pushNamed(CreateMediaScreen.route);
      return;
    }

    // Pause reels if leaving reels tab
    if (_selectedIndex == 3 && index != 3) {
      _reelsKey.currentState?.pause();
    }

    setState(() {
      _selectedIndex = index;
      _pages[index] ??= _buildPage(index);
    });

    // Play if entering reels
    if (index == 3) {
      _reelsKey.currentState?.playCurrent();
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return SearchScreen();
      case 3:
        return ReelsScreen(key: _reelsKey);
      case 4:
        return AccountScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<MainCubit>().setUserProfile();
    _pages[0] = _buildPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages.map((p) => p ?? const SizedBox()).toList()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: color.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.video_collection), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
