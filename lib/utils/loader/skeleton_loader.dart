import 'package:flutter/material.dart';

import 'custom_shimmer.dart';

class SkeletonLoader {
  static Widget skeletonSliverGrid({
    required BuildContext context,
    int crossAxisCount = 3,
    double crossAxisSpacing = 2,
    double mainAxisSpacing = 2,
    double horizontalPadding = 1.0,
    int itemCount = 9,
    BorderRadius itemBorderRadius = BorderRadius.zero, // ô vuông cho grid ảnh
  }) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: horizontalPadding),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((ctx, index) {
              return SizedBox.expand(
                child: SkeletonBox(
                  height: double.infinity,
                  borderRadius: itemBorderRadius,
                ),
              );
            }, childCount: itemCount),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: 1.0,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }

}