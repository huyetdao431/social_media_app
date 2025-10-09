import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/main_cubit/main_cubit.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';
import 'package:social_media_app/utils/dialogs.dart';
import 'package:social_media_app/utils/overlay.dart';

import '../../commons/widgets/display_video.dart';

class PreviewPostScreen extends StatelessWidget {
  static const String route = 'PreviewPostScreen';

  const PreviewPostScreen({super.key});

  @override
  Widget build(BuildContext context) => Theme(data: ThemeData.dark(), child: const _PreviewPostPage());
}

class _PreviewPostPage extends StatefulWidget {
  const _PreviewPostPage();

  @override
  State<_PreviewPostPage> createState() => _PreviewPostPageState();
}

class _PreviewPostPageState extends State<_PreviewPostPage> {
  final TextEditingController _captionController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _selectedIndex = 0;

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onShare(BuildContext context) {
    final cubit = context.read<PostCubit>();
    cubit.createPost(context.read<MainCubit>().state.profile!.id, _captionController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
  listener: (context, state) async {
    if(state.loadStatus == LoadStatus.loading) {
      LoadingOverlay.show(context);
    }
    if(state.loadStatus != LoadStatus.loading) {
      LoadingOverlay.hide();
    }
    if(state.loadStatus == LoadStatus.done) {
      final result = await showNotificationDialog(context, message: 'Create post successfully!');
      if(result! && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.route, (Route<dynamic> route) => false,);
      }
    }
    if(state.loadStatus == LoadStatus.error) {
      showErrorDialog(context, state.errorMessage);
    }
  },
  builder: (context, state) {
    final cubit = context.read<PostCubit>();
    final assets = cubit.state.assets;
    final selectedAssets = cubit.state.selectedAssets;

    final screen = MediaQuery.of(context).size;
    final double hei = screen.width * 0.7 / cubit.state.aspectRatio;
    final double aspectRatio = (cubit.state.aspectRatio) > 0 ? (cubit.state.aspectRatio) : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài viết mới'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TOP: preview area occupies half screen
            SizedBox(
              height: hei,
              width: double.infinity,
              child: _MediaCarousel(
                pageController: _pageController,
                assets: assets,
                selectedAssets: selectedAssets,
                onPageChanged: (idx) => setState(() => _selectedIndex = idx),
                selectedIndex: _selectedIndex,
                aspectRatio: aspectRatio,
                maxAreaHeight: hei,
              ),
            ),

            // caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
              child: TextField(
                controller: _captionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Viết chú thích...',
                  border: InputBorder.none,
                ),
              ),
            ),

            // action labels
            Expanded(
              child: ListView(
                children: [
                  _ActionRow(icon: Icons.person_add, label: 'Gắn thẻ người', onTap: () {}),
                  _ActionRow(icon: Icons.location_on_outlined, label: 'Thêm địa điểm', onTap: () {}),
                  _ActionRow(icon: Icons.more_horiz, label: 'Tùy chọn khác', onTap: () {}),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _onShare(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Chia sẻ', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        height: 56,
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }
}

class _MediaCarousel extends StatelessWidget {
  final PageController pageController;
  final List assets;
  final List<AssetEntity> selectedAssets;
  final ValueChanged<int> onPageChanged;
  final int selectedIndex;
  final double aspectRatio;
  final double maxAreaHeight;

  const _MediaCarousel({
    required this.pageController,
    required this.assets,
    required this.selectedAssets,
    required this.onPageChanged,
    required this.selectedIndex,
    required this.aspectRatio,
    required this.maxAreaHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('Không có ảnh hoặc video', style: TextStyle(color: Colors.white)));
    }

    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      final double maxHeight = maxAreaHeight; // half screen

      // PageController's viewportFraction controls visible portion horizontally (set in parent controller)
      // We compute a base item width using viewportFraction, but adjust if aspectRatio would exceed maxHeight.
      final double viewportFraction = (pageController.viewportFraction > 0)
          ? pageController.viewportFraction
          : 0.7;

      double itemWidth = maxWidth * viewportFraction;
      double itemHeight = itemWidth / aspectRatio;

      if (itemHeight > maxHeight) {
        itemHeight = maxHeight;
        itemWidth = itemHeight * aspectRatio;
      }

      return Column(
        children: [
          SizedBox(
            height: maxHeight - 24,
            child: Center(
              child: PageView.builder(
                controller: pageController,
                itemCount: assets.length,
                onPageChanged: onPageChanged,
                padEnds: true,
                itemBuilder: (context, index) {
                  final asset = selectedAssets.length > index ? selectedAssets[index] : null;
                  final file = assets[index]['file'] as File?;

                  return Center(
                    child: SizedBox(
                      width: itemWidth,
                      height: itemHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: Colors.black,
                            width: double.infinity,
                            height: double.infinity,
                            child: file == null
                                ? const SizedBox()
                                : asset?.type == AssetType.image
                                ? Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                : SmartVideo(
                              key: ValueKey(asset?.id ?? index),
                              file: file,
                              shouldPlay: index == selectedIndex,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // dot indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _DotIndicator(length: assets.length, active: selectedIndex),
          ),
        ],
      );
    });
  }
}

class _DotIndicator extends StatelessWidget {
  final int length;
  final int active;

  const _DotIndicator({required this.length, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white24,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
