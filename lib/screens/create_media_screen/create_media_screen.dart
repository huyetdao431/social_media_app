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
  late final PageController _pageController;
  final CarouselSliderController _carouselController = CarouselSliderController();

  final List<Widget> screens = const [
    AddPostScreen(),
    AddReelScreen(),
    AddStoryScreen(),
  ];

  final List<String> labels = ["Bài đăng", "Reels", "Tin"];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: screens.length,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
              _carouselController.animateToPage(index);
            },
            itemBuilder: (context, index) => screens[index],
          ),
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
            carouselController: _carouselController,
            itemCount: labels.length,
            itemBuilder: (context, index, _) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                _carouselController.animateToPage(index);
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.subHeadline(context).copyWith(
                  color: _selectedIndex == index ? Colors.white : Colors.grey,
                  fontWeight: _selectedIndex == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
                child: Text(labels[index]),
              ),
            ),
            options: CarouselOptions(
              height: 32,
              viewportFraction: 0.4,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              initialPage: _selectedIndex,
              onPageChanged: (index, reason) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
