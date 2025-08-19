import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';

import 'edit_image_screen.dart';

class EditMediaScreen extends StatelessWidget {
  static const String route = 'EditMediaScreen';
  final List<AssetEntity> assets;

  const EditMediaScreen({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: BlocProvider(
        create: (context) => PostCubit()..loadSelectedAssets(assets),
        child: const Page(),
      ),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  final PageController _controller = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openMenu(BuildContext context, Offset offset) async {
    final screenSize = MediaQuery.sizeOf(context);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        screenSize.width - offset.dx,
        screenSize.height - offset.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'portrait',
          child: Row(
            children: [
              Icon(Icons.crop_portrait),
              SizedBox(width: 6),
              Text('Doc'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'square',
          child: Row(
            children: [
              Icon(Icons.crop_square),
              SizedBox(width: 6),
              Text('Vuong'),
            ],
          ),
        ),
      ],
    );

    if (selected != null) {
      if (!context.mounted) return;
      setState(() {
        context.read<PostCubit>().updateAspectRatio(
          selected == 'square' ? 1 : 4 / 5,
        );
      });
    }
  }

  void _gotoEditScreen(PostCubit cubit) {
    Navigator.of(
      context,
    ).pushNamed(EditImageScreen.route, arguments: {'cubit': cubit});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return BlocBuilder<PostCubit, PostState>(
      buildWhen:
          (previous, current) =>
              previous.selectedAssets != current.selectedAssets ||
              previous.selectedIndex != current.selectedIndex ||
              previous.loadStatus != current.loadStatus,
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        var selectedIndex = state.selectedIndex;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
          ),
          body:
              state.loadStatus == LoadStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Stack(
                            children: [
                              SizedBox(
                                height:
                                    cubit.state.aspectRatio == 1
                                        ? screenWidth
                                        : screenWidth * 1.3,
                                child: PageView.builder(
                                  controller: _controller,
                                  itemCount: cubit.state.selectedAssets.length,
                                  onPageChanged: (index) {
                                    cubit.setIndex(index);
                                  },
                                  itemBuilder: (context, index) {
                                    var imageWidth = screenWidth * 0.9;
                                    var imageHeight =
                                        cubit.state.aspectRatio == 1
                                            ? screenWidth * 0.9
                                            : screenWidth * 0.9 / 4 * 5;
                                    return Center(
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _gotoEditScreen(cubit),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: imageWidth,
                                                  height: imageHeight,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  clipBehavior: Clip.hardEdge,
                                                  child:
                                                      cubit
                                                                  .state
                                                                  .selectedAssets[index]
                                                                  .type ==
                                                              AssetType.image
                                                          ? AssetEntityImage(
                                                            cubit
                                                                .state
                                                                .selectedAssets[index],
                                                            fit: BoxFit.cover,
                                                            isOriginal: true,
                                                          )
                                                          : Video(
                                                            key: ValueKey(
                                                              cubit
                                                                  .state
                                                                  .selectedAssets[index]
                                                                  .id,
                                                            ),
                                                            video:
                                                                cubit
                                                                    .state
                                                                    .selectedAssets[index],
                                                            shouldPlay:
                                                                cubit
                                                                    .state
                                                                    .selectedAssets
                                                                    .indexOf(
                                                                      cubit
                                                                          .state
                                                                          .selectedAssets[index],
                                                                    ) ==
                                                                cubit
                                                                    .state
                                                                    .selectedIndex,
                                                          ),
                                                ),

                                                if (cubit
                                                        .state
                                                        .selectedAssets
                                                        .length >
                                                    2)
                                                  Positioned(
                                                    top: 0,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          cubit.removeAsset();
                                                          if (cubit
                                                              .state
                                                              .selectedAssets
                                                              .isEmpty) {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          } else if (selectedIndex !=
                                                              0) {
                                                            _controller.jumpToPage(
                                                              selectedIndex >=
                                                                      cubit
                                                                          .state
                                                                          .selectedAssets
                                                                          .length
                                                                  ? selectedIndex -
                                                                      1
                                                                  : selectedIndex,
                                                            );
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              2,
                                                            ),
                                                        decoration:
                                                            BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color: AppColors
                                                                  .textDark
                                                                  .withAlpha(
                                                                    160,
                                                                  ),
                                                            ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color:
                                                              AppColors
                                                                  .textLight,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                bottom: screenWidth * 0.1 / 2 - 14,
                                left: screenWidth * 0.1 / 2 - 14,
                                child: GestureDetector(
                                  onPanEnd: (details) {
                                    _openMenu(context, details.globalPosition);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textMutedLight.withAlpha(
                                        160,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.fullscreen,
                                      color: AppColors.textLight,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _gotoEditScreen(cubit),
                        child: Container(
                          width: screenWidth * 0.64,
                          height: 36,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.textMutedLight.withAlpha(128),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Chỉnh sửa',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.subHeadlineDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textLight,
                                    width: 3,
                                  ),
                                  color: AppColors.textLight.withAlpha(32),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  children: [
                                    Opacity(
                                      opacity: 0.5,
                                      child: AssetEntityImage(
                                        cubit.state.selectedAssets[0],
                                        fit: BoxFit.cover,
                                        isOriginal: true,
                                      ),
                                    ),
                                    Center(
                                      child: Icon(
                                        Icons.add,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox.shrink(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Tiếp',
                                          style: TextStyle(
                                            color: AppColors.textLight,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: AppColors.textLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
