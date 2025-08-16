import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/materials/app_colors.dart';

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
        create: (context) => PostCubit(),
        child: Page(assets: assets),
      ),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key, required this.assets});

  final List<AssetEntity> assets;

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PostCubit>().loadSelectedAssets(widget.assets);
    });
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
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        var selectedIndex = state.seletedIndex;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
            ),
          ),
          body:
              state.loadStatus == LoadStatus.loading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Stack(
                            children: [
                              SizedBox(
                                height: screenWidth,
                                child: CarouselSlider(
                                  items: [
                                    for (var item in cubit.state.selectedAssets)
                                      Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _gotoEditScreen(cubit),
                                            child: Container(
                                              width: screenWidth,
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: Image.memory(
                                                item,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
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
                                                    Navigator.pop(context);
                                                  } else {
                                                    if (selectedIndex != 0) {
                                                      selectedIndex -=
                                                          selectedIndex >=
                                                                  cubit
                                                                      .state
                                                                      .selectedAssets
                                                                      .length
                                                              ? 1
                                                              : 0;
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors
                                                      .textMutedLight
                                                      .withAlpha(160),
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: AppColors.textLight,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                  options: CarouselOptions(
                                    height: screenWidth * 0.9,
                                    viewportFraction: 0.9,
                                    enableInfiniteScroll: false,
                                    autoPlay: false,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        cubit.setIndex(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: screenWidth * 0.1 / 2 - 14,
                                left: screenWidth * 0.1 / 2 - 14,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textMutedLight.withAlpha(
                                        160,
                                      ),
                                    ),
                                    child: Icon(
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
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildEditButton(
                            context,
                            Icon(Icons.text_fields, color: AppColors.textLight),
                            'van ban',
                            () {},
                          ),
                          _buildEditButton(
                            context,
                            Icon(Icons.image, color: AppColors.textLight),
                            'lop phu',
                            () {},
                          ),
                          _buildEditButton(
                            context,
                            Icon(Icons.filter_list, color: AppColors.textLight),
                            'bo loc',
                            () {},
                          ),
                          _buildEditButton(
                            context,
                            Icon(Icons.tune, color: AppColors.textLight),
                            'chinh sua',
                            () {},
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox.shrink(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Tiep',
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
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
                      ),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    Icon icon,
    String label,
    VoidCallback opTap,
  ) {
    return Container(
      width: 64,
      height: 48,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.textMutedLight.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          icon,
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.subHeadlineDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
