import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/materials/app_text_styles.dart';
import 'package:social_media_app/screens/search_screen/cubit/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  static const String route = 'SearchScreen';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => SearchCubit(), child: Scaffold(body: Page()));
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
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        var cubit = context.read<SearchCubit>();
        return cubit.state.isSearchPage ? SearchPage() : ExplorePage();
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
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        var cubit = context.read<SearchCubit>();
        return Column(
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  cubit.togglePage();
                });
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

class _SearchPageState extends State<SearchPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController(text: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        var cubit = context.read<SearchCubit>();
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        cubit.togglePage();
                      });
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _searchController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Input search information',
                        hintStyle: TextStyle(color: theme.hintColor),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest, // phù hợp với dark/light mode
                      ),
                      style: TextStyle(color: colorScheme.onSurface),
                      // màu chữ
                      cursorColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Column(
                    children: [
                      Align(alignment: Alignment.centerLeft, child: Text('recently', style: AppTextStyles.subHeadline(context))),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/avt_02.png'), backgroundColor: Colors.transparent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text('username', style: AppTextStyles.username(context)), Text('Name', style: AppTextStyles.name(context))],
                            ),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.close, size: 16)),
                        ],
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
}
