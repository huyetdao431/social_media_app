// import 'package:flutter/material.dart';
// import 'package:social_media_app/screens/account_screen/account_setting_screen.dart';
// import 'package:social_media_app/screens/add_post_screen/add_post_screen.dart';
// import 'package:social_media_app/screens/post_list_screen/post_list_screen.dart';
//
// import '../../materials/app_colors.dart';
// import '../../materials/app_text_styles.dart';
//
// class AccountScreen extends StatefulWidget {
//   static const String route = 'AccountScreen';
//
//   const AccountScreen({super.key});
//
//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }
//
// class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin  {
//   final ScrollController _scrollController = ScrollController();
//   late TabController _tabController;
//   int itemCount = 12;
//   bool isLoadMore = false;
//   int currentTabIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent) {
//       loadMorePost();
//     }
//   }
//
//   void loadMorePost() {
//     if (!isLoadMore) {
//       setState(() => isLoadMore = true);
//       Future.delayed(Duration(seconds: 1), () {
//         setState(() {
//           itemCount += 6;
//           isLoadMore = false;
//         });
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('username'),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.add_box_outlined),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(AccountSettingScreen.route);
//             },
//             icon: Icon(Icons.dehaze),
//           ),
//         ],
//       ),
//       body: NestedScrollView(
//         controller: _scrollController,
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverToBoxAdapter(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 16),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildProfileInfo(),
//                         _buildDescription(),
//                       ],
//                     ),
//                   ),
//                   TabBar(
//                     controller: _tabController,
//                     indicatorColor: Colors.black,
//                     labelColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: const [
//                       Tab(icon: Icon(Icons.grid_on)),
//                       Tab(icon: Icon(Icons.video_collection_outlined)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             ListImages(itemCount: itemCount),
//             ListVideos(itemCount: itemCount),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildProfileInfo() {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () {},
//           child: SizedBox(
//             height: 100,
//             width: 72,
//             child: Stack(
//               children: [
//                 Positioned(
//                   bottom: 0,
//                   child: CircleAvatar(
//                     radius: 36,
//                     backgroundColor: Colors.transparent,
//                     backgroundImage: AssetImage('assets/images/avt_13.png'),
//                   ),
//                 ),
//                 Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       border: Border.all(width: 1.5, color: Colors.black),
//                     ),
//                     child: const Icon(Icons.add, size: 20, color: Colors.black),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppColors.textMutedDark,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     'Ban dang nghi gi?',
//                     style: AppTextStyles.badge(context),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('name', style: AppTextStyles.subHeadline(context)),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildStatColumn('20', 'Bài viết'),
//                   _buildStatColumn('1.2K', 'Người theo dõi'),
//                   _buildStatColumn('200', 'Đang theo dõi'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatColumn(String data, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(data, style: AppTextStyles.subHeadline(context)),
//         Text(label, style: AppTextStyles.caption(context)),
//       ],
//     );
//   }
//
//   Widget _buildDescription() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 16),
//         Text('description'),
//         Text('links'),
//         Row(
//           children: [
//             ElevatedButton(onPressed: () {}, child: Text('Edit Profile')),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class ListVideos extends StatelessWidget {
//   final int itemCount;
//   const ListVideos({super.key, required this.itemCount});
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 2,
//         crossAxisSpacing: 2,
//         childAspectRatio: 1,
//       ),
//       itemCount: itemCount,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.of(context).pushNamed(PostListScreen.route, arguments: {'initialIndex' : index});
//           },
//           child: Stack(
//             children: [
//               Container(
//                 color:
//                 index % 2 == 0
//                     ? Theme.of(context).colorScheme.primary
//                     : Theme.of(context).colorScheme.error,
//                 child: Image.asset(
//                   'assets/images/avt_09.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Icon(Icons.filter_none, color: AppColors.textLight),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class ListImages extends StatelessWidget {
//   final int itemCount;
//   const ListImages({super.key, required this.itemCount});
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 2,
//         crossAxisSpacing: 2,
//         childAspectRatio: 1,
//       ),
//       itemCount: itemCount,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.of(context).pushNamed(PostListScreen.route, arguments: {'initialIndex' : index});
//           },
//           child: Stack(
//             children: [
//               Container(
//                 color:
//                 index % 2 == 0
//                     ? Theme.of(context).colorScheme.primary
//                     : Theme.of(context).colorScheme.error,
//                 child: Image.asset(
//                   'assets/images/avt_06.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Icon(Icons.filter_none, color: AppColors.textLight),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/account_screen/account_setting_screen.dart';
import '../../materials/app_colors.dart';
import '../../materials/app_text_styles.dart';
import '../post_list_screen/post_list_screen.dart';

class AccountScreen extends StatefulWidget {
  static const String route = 'AccountScreen';

  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  int photoCount = 12;
  int videoCount = 9;
  bool isLoadMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!isLoadMore) {
      setState(() => isLoadMore = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (_tabController.index == 0) {
            photoCount += 6;
          } else {
            videoCount += 4;
          }
          isLoadMore = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('username'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AccountSettingScreen.route);
            },
            icon: const Icon(Icons.dehaze),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Profile info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [_buildProfileInfo(), _buildDescription()],
              ),
            ),
          ),

          // TabBar ghim
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppColors.surfaceDark
                        : AppColors.textLight,
                unselectedLabelColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppColors.textMutedLight
                        : AppColors.subHeadlineDark,
                tabs: [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.video_collection_outlined)),
                ],
              ),
            ),
          ),

          // Nội dung theo tab
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                return _tabController.index == 0
                    ? _buildPhotoGrid()
                    : _buildVideoGrid();
              },
            ),
          ),

          // Loading indicator
          SliverToBoxAdapter(
            child:
                isLoadMore
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: SizedBox(
            height: 100,
            width: 72,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/avt_13.png'),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(width: 1.5, color: Colors.black),
                    ),
                    child: const Icon(Icons.add, size: 20, color: Colors.black),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textMutedDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Ban dang nghi gi?',
                    style: AppTextStyles.badge(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('name', style: AppTextStyles.subHeadline(context)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn('20', 'Bài viết'),
                  _buildStatColumn('1.2K', 'Người theo dõi'),
                  _buildStatColumn('200', 'Đang theo dõi'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String data, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data, style: AppTextStyles.subHeadline(context)),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text('description'),
        Text('links'),
        Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text('Edit Profile')),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: photoCount,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              PostListScreen.route,
              arguments: {'initialIndex': index},
            );
          },
          child: Stack(
            children: [
              Container(
                color:
                    index % 2 == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                child: Image.asset(
                  'assets/images/avt_09.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.filter_none, color: AppColors.textLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: videoCount,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              PostListScreen.route,
              arguments: {'initialIndex': index},
            );
          },
          child: Stack(
            children: [
              Container(
                color:
                    index % 2 == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                child: Image.asset(
                  'assets/images/avt_09.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.filter_none, color: AppColors.textLight),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
