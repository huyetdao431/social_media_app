import 'package:flutter/material.dart';

import 'custom_shimmer.dart';

/// CommentTileSkeleton
class CommentTileSkeleton extends StatelessWidget {
  final int depth;
  final int maxDepth;
  final int replyCount;
  final bool showReplies; // nếu true sẽ mở rộng và hiển thị reply skeletons
  final double avatarRadius;

  const CommentTileSkeleton({
    super.key,
    this.depth = 0,
    this.maxDepth = 2,
    this.replyCount = 2,
    this.showReplies = false,
    this.avatarRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar skeleton
          SizedBox(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            child: ClipOval(
              child: SkeletonBox(
                height: avatarRadius * 2,
                width: avatarRadius * 2,
                borderRadius: BorderRadius.circular(avatarRadius),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // username + short caption line (single row)
                Row(
                  children: [
                    // username
                    const Flexible(
                      child: SkeletonBox(height: 14, width: 120, borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                    const SizedBox(width: 8),
                    // small time/caption short
                    const SkeletonBox(height: 12, width: 60, borderRadius: BorderRadius.all(Radius.circular(6))),
                  ],
                ),

                const SizedBox(height: 8),

                // caption lines (1-2 lines)
                const SkeletonBox(height: 12, width: double.infinity, borderRadius: BorderRadius.all(Radius.circular(6))),
                const SizedBox(height: 6),
                const SkeletonBox(height: 12, width: 220, borderRadius: BorderRadius.all(Radius.circular(6))),

                const SizedBox(height: 8),

                // action row: like icon, likes count, reply text, show replies button
                Row(
                  children: [
                    // like icon skeleton (square)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: SkeletonBox(height: 20, width: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
                    ),
                    const SizedBox(width: 8),
                    // likes count small
                    const SkeletonBox(height: 12, width: 24, borderRadius: BorderRadius.all(Radius.circular(6))),
                    const SizedBox(width: 16),
                    // reply text skeleton
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: const SkeletonBox(height: 12, width: 50, borderRadius: BorderRadius.all(Radius.circular(6))),
                      ),
                    ),

                    // show/hide replies button skeleton (if allowed by depth)
                    // if (depth < maxDepth)
                    //   Padding(
                    //     padding: const EdgeInsets.only(left: 8.0),
                    //     child: SkeletonBox(height: 28, width: 120, borderRadius: BorderRadius.all(Radius.circular(6))),
                    //   ),
                  ],
                ),

                // nested reply skeletons (optional)
                // if (showReplies && depth < maxDepth)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 8.0),
                //     child: Column(
                //       children: List.generate(replyCount, (i) {
                //         return Padding(
                //           padding: const EdgeInsets.only(top: 8.0),
                //           child: CommentTileSkeleton(
                //             depth: depth + 1,
                //             maxDepth: maxDepth,
                //             replyCount: replyCount,
                //             showReplies: false, // nested replies collapsed by default
                //             avatarRadius: avatarRadius - 2,
                //           ),
                //         );
                //       }),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
