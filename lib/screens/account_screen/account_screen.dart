import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:social_media_app/cubit/main_cubit/main_cubit.dart';
import 'package:social_media_app/cubit/profile_cubit/profile_cubit.dart';
import 'package:social_media_app/screens/account_screen/account_setting_screen.dart';
import 'package:social_media_app/screens/account_screen/edit_profile_screen.dart';
import 'package:social_media_app/screens/post_list_screen/post_list_screen.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

import '../../materials/app_text_styles.dart';

class AccountScreen extends StatelessWidget {
  static const String route = 'AccountScreen';

  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainProfile = context.read<MainCubit>().state.profile;

    return BlocProvider(create: (context) => ProfileCubit(context.read<Api>())..loadProfile(mainProfile!), child: const _AccountPage());
  }
}

class _AccountPage extends StatefulWidget {
  const _AccountPage({Key? key}) : super(key: key);

  @override
  State<_AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<_AccountPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _outerScrollController;

  int _photoCount = 12;
  int _videoCount = 9;
  bool _isLoadMore = false;

  static const double _loadMoreThreshold = 200;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _outerScrollController = ScrollController();
  }

  void _tryLoadMore() {
    if (_isLoadMore) return;
    setState(() => _isLoadMore = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        if (_tabController.index == 0) {
          _photoCount += 6;
        } else {
          _videoCount += 4;
        }
        _isLoadMore = false;
      });
    });
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final username = state.userProfile?.username ?? 'username';
            return Text(username, style: theme.textTheme.headlineLarge);
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.add_box_outlined, color: onSurface)),
          IconButton(onPressed: () => Navigator.of(context).pushNamed(AccountSettingScreen.route), icon: Icon(Icons.dehaze, color: onSurface)),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final profile = state.userProfile;
          final cubit = context.read<ProfileCubit>();

          return NestedScrollView(
            controller: _outerScrollController,
            headerSliverBuilder:
                (context, innerScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      child: _ProfileHeader(
                        profile: profile,
                        onEditProfile: () {
                          Navigator.of(context).pushNamed(EditProfileScreen.route, arguments: {'cubit' : cubit});
                        },
                      ),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicatorColor: primary,
                        labelColor: primary,
                        unselectedLabelColor: onSurface.withAlpha(153),
                        tabs: [Tab(icon: Icon(Icons.grid_on)), Tab(icon: Icon(Icons.video_collection_outlined))],
                      ),
                    ),
                  ),
                ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Photos tab
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - _loadMoreThreshold) {
                      _tryLoadMore();
                    }
                    return false;
                  },
                  child: _MediaGrid(
                    itemCount: _photoCount,
                    onTapItem: (index) => Navigator.of(context).pushNamed(PostListScreen.route, arguments: {'initialIndex': index}),
                  ),
                ),

                // Videos tab
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - _loadMoreThreshold) {
                      _tryLoadMore();
                    }
                    return false;
                  },
                  child: _MediaGrid(
                    itemCount: _videoCount,
                    onTapItem: (index) => Navigator.of(context).pushNamed(PostListScreen.route, arguments: {'initialIndex': index}),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _isLoadMore ? SizedBox(height: 52, child: Center(child: CircularProgressIndicator(color: primary))) : null,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onEditProfile;

  const _ProfileHeader({required this.profile, required this.onEditProfile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    final name = profile?.displayName ?? profile?.username ?? 'Name';
    final bio = profile?.bio ?? 'No bio yet';
    final avatarUrl = profile?.avatarUrl as String?;
    final posts = '0';
    final followers = '0';
    final following = '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar + add icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: surface,
                  backgroundImage:
                      avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : const AssetImage('assets/images/avt_13.png') as ImageProvider,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 2, bottom: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.scaffoldBackgroundColor,
                    border: Border.all(width: 1.2, color: onSurface.withAlpha(31)),
                  ),
                  child: Padding(padding: const EdgeInsets.all(4.0), child: Icon(Icons.add, size: 16, color: onSurface.withAlpha(204))),
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Name + stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.subHeadline(context)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatColumn(data: posts, label: 'Bài viết'),
                      _StatColumn(data: followers, label: 'Người theo dõi'),
                      _StatColumn(data: following, label: 'Đang theo dõi'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Bio + link row
        Text(bio, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),

        // Actions
        Row(
          children: [
            ElevatedButton(
              onPressed: onEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                textStyle: theme.textTheme.bodyMedium,
              ),
              child: const Text('Edit Profile'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary.withAlpha(31)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                textStyle: theme.textTheme.bodyMedium,
              ),
              child: const Text('Follow'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String data;
  final String label;

  const _StatColumn({required this.data, required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(data, style: AppTextStyles.subHeadline(context)), Text(label, style: AppTextStyles.caption(context))],
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final int itemCount;
  final void Function(int index) onTapItem;

  const _MediaGrid({required this.itemCount, required this.onTapItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTapItem(index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: theme.colorScheme.surface,
                child: Image.asset('assets/images/avt_09.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
              Positioned(top: 8, right: 8, child: Icon(Icons.filter_none, size: 18, color: theme.colorScheme.onSurface.withAlpha(115))),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}
