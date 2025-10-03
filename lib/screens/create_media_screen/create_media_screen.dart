import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';

import '../../materials/app_text_styles.dart';
import '../add_reel_screen/add_reel_screen.dart';
import '../add_story_screen/add_story_screen.dart';

class CreateMediaScreen extends StatelessWidget {
  static const String route = 'CreateMediaScreen';
  const CreateMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateMediaPage();
  }
}

class CreateMediaPage extends StatefulWidget {
  const CreateMediaPage({super.key});

  @override
  State<CreateMediaPage> createState() => _CreateMediaPageState();
}

class _CreateMediaPageState extends State<CreateMediaPage> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    AddPostScreen(),
    AddReelScreen(),
    AddStoryScreen(),
  ];

  final List<String> labels = ["Bài đăng", "Reels", "Tin"];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Stack(
        children: [
          screens[_selectedIndex],
          _buildSelectionTabs(context),
        ],
      ),
    );
  }

  Widget _buildSelectionTabs(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
          ),
          child: CarouselSlider.builder(
            itemCount: labels.length,
            itemBuilder: (context, index, _) => Center(
              child: Text(
                labels[index],
                style: AppTextStyles.subHeadline(context).copyWith(
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            options: CarouselOptions(
              height: 50,
              viewportFraction: 0.4,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() => _selectedIndex = index);
                // TODO: Lọc gallery theo tab (nếu cần)
              },
            ),
          ),
        ),
      ),
    );
  }
}
