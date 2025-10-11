import 'package:flutter/material.dart';

import 'custom_shimmer.dart';

class PostWidgetSkeleton extends StatelessWidget {
  final double aspectRatio;

  final BorderRadius mediaBorderRadius;

  const PostWidgetSkeleton({super.key, this.aspectRatio = 1.0, this.mediaBorderRadius = BorderRadius.zero});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 44;
    // final mediaHeight = MediaQuery.of(context).size.width / aspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              ClipOval(child: SkeletonBox(height: avatarSize, width: avatarSize, borderRadius: BorderRadius.circular(avatarSize / 2))),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(height: 14, width: 140, borderRadius: BorderRadius.all(Radius.circular(6))),
                    SizedBox(height: 6),
                    SkeletonBox(height: 12, width: 90, borderRadius: BorderRadius.all(Radius.circular(6))),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const SkeletonBox(height: 28, width: 28, borderRadius: BorderRadius.all(Radius.circular(6))),
            ],
          ),
        ),

        const SizedBox(height: 8),

        AspectRatio(
          aspectRatio: aspectRatio > 0 ? aspectRatio : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: ClipRRect(
              borderRadius: mediaBorderRadius,
              child: const SizedBox.expand(child: SkeletonBox(height: double.infinity, borderRadius: BorderRadius.zero)),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // indicator (small grey bar to simulate dots)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: SkeletonBox(height: 8, width: 110, borderRadius: BorderRadius.circular(20)),
          ),
        ),

        const SizedBox(height: 8),

        // Action row (like/comment/share/save) - show circular skeletons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: const [
              SizedBox(width: 32, height: 32, child: SkeletonBox(height: 32, width: 32, borderRadius: BorderRadius.all(Radius.circular(8)))),
              SizedBox(width: 12),
              SizedBox(width: 32, height: 32, child: SkeletonBox(height: 32, width: 32, borderRadius: BorderRadius.all(Radius.circular(8)))),
              SizedBox(width: 12),
              SizedBox(width: 32, height: 32, child: SkeletonBox(height: 32, width: 32, borderRadius: BorderRadius.all(Radius.circular(8)))),
              Spacer(),
              SizedBox(width: 28, height: 28, child: SkeletonBox(height: 28, width: 28, borderRadius: BorderRadius.all(Radius.circular(6)))),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Likes + caption + comments lines (skeleton text lines)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(height: 14, width: 140, borderRadius: BorderRadius.all(Radius.circular(6))), // likes count
              SizedBox(height: 6),
              SkeletonBox(height: 12, width: double.infinity, borderRadius: BorderRadius.all(Radius.circular(6))), // caption line 1
              SizedBox(height: 6),
              SkeletonBox(height: 12, width: 200, borderRadius: BorderRadius.all(Radius.circular(6))), // caption line 2 (short)
              SizedBox(height: 10),
              SkeletonBox(height: 12, width: 160, borderRadius: BorderRadius.all(Radius.circular(6))), // view comments
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
