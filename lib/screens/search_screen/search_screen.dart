import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/cubit/search_bloc/search_bloc.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/materials/app_text_styles.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

class SearchScreen extends StatelessWidget {
  static const String route = 'SearchScreen';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SearchBloc(context.read<Api>()), child: Scaffold(body: SafeArea(child: Page())));
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        var bloc = context.read<SearchBloc>();
        return bloc.state.isSearchPage ? SearchPage() : ExplorePage();
      },
    );
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController scrollController = ScrollController();
  int _itemCount = 20;
  bool isLoadingMore = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent && !isLoadingMore) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() async {
    setState(() {
      isLoadingMore = true;
    });

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _itemCount += 5;
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final isSearchPage = context.read<SearchBloc>().state.isSearchPage;
        return Column(
          children: [
            ListTile(
              onTap: () {
                context.read<SearchBloc>().add(SwitchPageEvent(isSearchPage: !isSearchPage));
              },
              title: Text('input search information'),
              leading: Icon(Icons.search),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 1),
                itemCount: _itemCount + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isLoadingMore && index == _itemCount) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return GestureDetector(
                    onTap: () {
                      print('show post');
                    },
                    child: Stack(
                      children: [
                        Container(
                          color: index % 2 == 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                          child: Image.asset('assets/images/avt_10.png', fit: BoxFit.cover),
                        ),
                        Positioned(top: 8, right: 8, child: Icon(Icons.filter_none, color: AppColors.textLight)),
                      ],
                    ),
                  );
                },
              ),
            ),
            // isLoadingMore
            //     ? Center(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 16.0),
            //         child: CircularProgressIndicator(),
            //       ),
            //     )
            //     : SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController(text: '');

  late final TabController _tabController;
  final List<String> _tabs = ['For you', 'Posts', 'Reels'];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> _filterList(List<String> source) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final isSearchPage = context.read<SearchBloc>().state.isSearchPage;
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<SearchBloc>().add(SwitchPageEvent(isSearchPage: !isSearchPage));
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _searchController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Input search information',
                        hintStyle: TextStyle(color: theme.hintColor),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      style: TextStyle(color: colorScheme.onSurface),
                      cursorColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Expanded(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              //     child: Column(
              //       children: [
              //         Align(alignment: Alignment.centerLeft, child: Text('recently', style: AppTextStyles.subHeadline(context))),
              //         SizedBox(height: 12),
              //         Row(
              //           children: [
              //             CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/avt_02.png'), backgroundColor: Colors.transparent),
              //             SizedBox(width: 12),
              //             Expanded(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [Text('username', style: AppTextStyles.username(context)), Text('Name', style: AppTextStyles.name(context))],
              //               ),
              //             ),
              //             IconButton(onPressed: () {}, icon: Icon(Icons.close, size: 16)),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              _buildSearchResultScreen(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultScreen() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            indicator: UnderlineTabIndicator(borderSide: BorderSide(width: 3, color: Theme.of(context).colorScheme.onSurface)),
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All: gom tất cả kết quả

                // People
                _buildResultsList(items: _filterList([]), emptyLabel: 'No people found'),

                // Tags
                _buildResultsList(items: _filterList([]), emptyLabel: 'No tags found'),

                // Posts
                _buildResultsList(items: _filterList([]), emptyLabel: 'No posts found'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList({required List<String> items, required String emptyLabel}) {
    if (items.isEmpty) {
      return Center(child: Text(emptyLabel, style: Theme.of(context).textTheme.bodyMedium));
    }

    return ListView.separated(
      key: PageStorageKey<String>(emptyLabel), // giữ trạng thái cuộn cho từng tab
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(child: Text(item.isNotEmpty ? item[0].toUpperCase() : '?')),
          title: Text(item),
          subtitle: Text('Some extra info'),
          onTap: () {
            // xử lý khi bấm kết quả
          },
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }
}
