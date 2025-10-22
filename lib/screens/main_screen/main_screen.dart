import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/create_media_screen/create_media_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/reels_screen/reels_screen.dart';
import 'package:social_media_app/screens/search_screen/search_screen.dart';

import '../../cubit/main_cubit/main_cubit.dart';
import '../../cubit/profile_cubit/profile_cubit.dart';
import '../../utils/screen_trasition/slide_in_from_right.dart';
import '../account_screen/account_setting_screen.dart';
import '../account_screen/edit_profile_screen.dart';
import '../account_screen/list_profile_post_screen.dart';
import '../account_screen/list_profile_reel_screen.dart';

class MainScreen extends StatefulWidget {
  static const String route = 'MainScreen';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget?> _pages = List.filled(5, null);
  final GlobalKey<ReelPageState> _reelsKey = GlobalKey<ReelPageState>();
  bool _createMediaOpening = false;

  void onItemTapped(int index) {
    if (index == 2) {
      Navigator.of(context).pushNamed(CreateMediaScreen.route);
      return;
    }

    if (_selectedIndex == 3 && index != 3) {
      _reelsKey.currentState?.pause();
    }

    setState(() {
      _selectedIndex = index;
      _pages[index] ??= _buildPage(index);
    });

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
        return Navigator(
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case EditProfileScreen.route:
                final args = settings.arguments as Map<String, dynamic>;
                final cubit = args['cubit'] as ProfileCubit;
                return MaterialPageRoute(builder: (_) => BlocProvider.value(value: cubit, child: EditProfileScreen()));
              case AccountSettingScreen.route:
                return slideInFromRight(const AccountSettingScreen());
              case ListProfilePostScreen.route:
                var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ProfileCubit;
                return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: ListProfilePostScreen()));
              case ListProfileReelScreen.route:
                var cubit = (settings.arguments as Map<String, dynamic>)['cubit'] as ProfileCubit;
                var index = (settings.arguments as Map<String, dynamic>)['index'] as int;
                return MaterialPageRoute(builder: (context) => BlocProvider.value(value: cubit, child: ListProfileReelScreen(index: index)));
              default:
                return MaterialPageRoute(builder: (_) => const AccountScreen());
            }
          },
        );
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
