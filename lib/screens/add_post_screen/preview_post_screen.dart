import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/materials/app_colors.dart';

import '../../commons/widgets/display_video.dart';

class PreviewPostScreen extends StatelessWidget {
  static const String route = 'PreviewPostScreen';

  const PreviewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: Page());
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  TextEditingController caption = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return Scaffold(
          appBar: AppBar(title: Text('bai viet moi')),
          body: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      //page view hien thi anh va video,
                      SizedBox(height: MediaQuery.sizeOf(context).width * 0.7, child: PostMediaView()),
                      //text field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                        child: TextField(controller: caption, decoration: InputDecoration(hintText: 'Add a caption...', border: InputBorder.none)),
                      ),
                      //label chuc nang
                      for (int i = 0; i < 5; i++) _buildNavigatorLabel(context, Icon(Icons.add, size: 32), 'add', () {}),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text('Share', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, fontSize: 14))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigatorLabel(BuildContext context, Icon icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        height: 54,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [icon, const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 17))]),
            ),
            Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }
}

class PostMediaView extends StatefulWidget {
  const PostMediaView({super.key});

  @override
  State<PostMediaView> createState() => _PostMediaViewState();
}

class _PostMediaViewState extends State<PostMediaView> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return PageView.builder(
          controller: _controller,
          itemCount: cubit.state.assets.length,
          onPageChanged: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              width: MediaQuery.sizeOf(context).width * 0.7,
              height: MediaQuery.sizeOf(context).width * 0.7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.hardEdge,
              child:
                  cubit.state.selectedAssets[index].type == AssetType.image
                      ? Image.file(cubit.state.assets[index], fit: BoxFit.cover)
                      : Video(
                        key: ValueKey(cubit.state.selectedAssets[index].id),
                        video: cubit.state.assets[index],
                        shouldPlay: cubit.state.assets.indexOf(cubit.state.assets[index]) == selectedIndex,
                      ),
            );
          },
        );
      },
    );
  }
}
