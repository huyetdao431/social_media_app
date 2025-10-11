import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/cubit/main_cubit/main_cubit.dart';
import 'package:social_media_app/cubit/profile_cubit/profile_cubit.dart';
import 'package:social_media_app/screens/account_screen/account_setting_screen.dart';
import 'package:social_media_app/screens/account_screen/edit_profile_screen.dart';
import 'package:social_media_app/screens/post_list_screen/post_list_screen.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'package:social_media_app/utils/loader/skeleton_loader.dart';

import '../../commons/enums/load_status.dart';
import '../../materials/app_text_styles.dart';
import '../../models/post.dart';

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
  const _AccountPage();

  @override
  State<_AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<_AccountPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _outerScrollController;
  static const double _loadMoreThreshold = 200;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _outerScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProfileCubit>();
      cubit.loadUserPosts();
    });
  }

  @override
  void dispose() {
    _outerScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _thumbnailForPost(Post post) {
    if (post.mediaList == null || post.mediaList!.isEmpty) return '';
    final first = post.mediaList!.first;
    return (first.thumbUrl?.isNotEmpty == true) ? first.thumbUrl! : first.mediaUrl;
  }

  bool _isPostVideo(Post post) {
    if (post.mediaList == null || post.mediaList!.isEmpty) return false;
    final first = post.mediaList!.first;
    return first.mediaType.toLowerCase().startsWith('video');
  }

  bool _isPostImage(Post post) {
    if (post.mediaList == null || post.mediaList!.isEmpty) return false;
    final first = post.mediaList!.first;
    return first.mediaType.toLowerCase().startsWith('image');
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
          final isLoading = state.loadPostStatus == LoadStatus.loading;
          final allPosts = state.userPosts;
          // final videoPosts = allPosts.where((p) => _isPostVideo(p)).toList();

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
                          Navigator.of(context).pushNamed(EditProfileScreen.route, arguments: {'cubit': cubit});
                        },
                      ),
                    ),
                  ),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverPersistentHeader(
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
                  ),
                ],
            body: TabBarView(
              controller: _tabController,
              children: [
                Builder(builder: (innerContext) {
                  return _buildTabContent(
                    context: innerContext,
                    postsToShow: allPosts,
                    isLoading: isLoading,
                    onLoadMore: () => cubit.loadMoreUserPosts(),
                    onTapItem: (index) {
                      cubit.setMediaIndex(index);
                      Navigator.of(innerContext).pushNamed(PostListScreen.route, arguments: {'cubit': cubit});
                    },
                  );
                }),

                Builder(builder: (innerContext) {
                  return _buildTabContent(
                    context: innerContext,
                    postsToShow: [],
                    isLoading: isLoading,
                    onLoadMore: () => cubit.loadMoreUserPosts(),
                    onTapItem: (index) {
                      cubit.setMediaIndex(index);
                      Navigator.of(innerContext).pushNamed(PostListScreen.route, arguments: {'cubit': cubit});
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent({
    required BuildContext context,
    required List<Post> postsToShow,
    required bool isLoading,
    required VoidCallback onLoadMore,
    required void Function(int index) onTapItem,
  }) {
    // grid configuration (giữ thống nhất với trước)
    const int crossAxisCount = 3;
    const double crossAxisSpacing = 2;
    const double mainAxisSpacing = 2;
    const double horizontalPadding = 1.0; // = padding left + right mỗi bên

    // Nếu đang load lần đầu và chưa có post => loader trung tâm
    if (isLoading && postsToShow.isEmpty) {
      return SkeletonLoader.skeletonSliverGrid(context: context);
    }

    // Nếu không load và không có post => "No Post Yet"
    if (!isLoading && postsToShow.isEmpty) {
      return Center(child: Text('No Post Yet', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500)));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final totalHorizontal = horizontalPadding * 2;
    final itemWidth = (screenWidth - totalHorizontal - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    final itemHeight = itemWidth;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - _loadMoreThreshold &&
            !(context.read<ProfileCubit>().state.loadPostStatus == LoadStatus.loading) &&
            context.read<ProfileCubit>().state.hasMorePosts) {
          onLoadMore();
        }
        return false;
      },

      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Inject overlap (bù phần header pinned)
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: horizontalPadding),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = postsToShow[index];
                final thumb = _thumbnailForPost(post);
                final hasMany = (post.mediaList?.length ?? 0) > 1;
                final isVideo = _isPostVideo(post);

                return GestureDetector(
                  onTap: () => onTapItem(index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: thumb,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(color: Colors.grey[300]),
                        errorWidget: (ctx, url, error) => Container(color: Colors.grey, child: const Icon(Icons.error)),
                      ),
                      if (hasMany)
                        Positioned(top: 4, right: 4, child: Icon(Icons.copy, size: 24, color: Colors.white.withAlpha(230)))
                      else if (isVideo)
                        Positioned(top: 4, right: 4, child: Icon(Icons.play_arrow, size: 24, color: Colors.white.withAlpha(230))),
                    ],
                  ),
                );
              }, childCount: postsToShow.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childAspectRatio: 1,
              ),
            ),
          ),

          // Footer loader: chỉ xuất hiện khi isLoading = true
          if (isLoading)
            SliverToBoxAdapter(
              child: SizedBox(
                height: itemHeight / 2,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onEditProfile;

  const _ProfileHeader({required this.profile, required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    final name = profile?.displayName ?? profile?.username ?? 'Name';
    final bio = profile?.bio ?? 'No bio yet';
    final avatarUrl = profile?.avatarUrl as String?;
    final posts = (profile?.postCount ?? 0).toString();
    final followers = (profile?.followersCount ?? 0).toString();
    final following = (profile?.followingCount ?? 0).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(color: Colors.grey[300]),
                    errorWidget: (ctx, url, error) => Container(color: Colors.grey, child: const Icon(Icons.error)),
                  ),
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

        Text(bio, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: theme.textTheme.bodyMedium,
                ),
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(width: 8,),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(color: theme.colorScheme.primary.withAlpha(31)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: theme.textTheme.bodyMedium,
                ),
                child: const Text('Follow'),
              ),
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

  const _StatColumn({required this.data, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(data, style: AppTextStyles.subHeadline(context)), Text(label, style: AppTextStyles.caption(context))],
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
