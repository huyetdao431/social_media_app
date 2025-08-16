import 'package:flutter/material.dart';
import 'package:social_media_app/screens/account_screen/account_screen.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';
import 'package:social_media_app/screens/home%20screen/home_screen.dart';
import 'package:social_media_app/screens/search_screen/search_screen.dart';

class MainScreen extends StatefulWidget {
  static const String route = 'MainScreen';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget?> _pages = List.filled(5, null); // ban đầu tất cả null

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Lazy load: chỉ khởi tạo khi cần
      _pages[index] ??= _buildPage(index);
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return SearchScreen();
      case 2:
        Navigator.of(context).pushNamed(AddPostScreen.route);
        return const SizedBox();
      case 3:
        return AccountScreen();
      case 4:
        return AccountScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo tab đầu tiên
    _pages[0] = _buildPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((p) => p ?? const SizedBox()).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: color.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddPostScreen.route);
              },
              icon: Icon(Icons.add_box_outlined),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
