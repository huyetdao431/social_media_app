import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:social_media_app/commons/widgets/post_widget.dart';
import 'package:social_media_app/cubit/profile_cubit/profile_cubit.dart';


class ListProfilePostScreen extends StatelessWidget {
  static const String route = 'ListProfilePostScreen';

  const ListProfilePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListPostsPage();
  }
}

class ListPostsPage extends StatefulWidget {
  const ListPostsPage({super.key});

  @override
  State<ListPostsPage> createState() => _ListPostsPageState();
}

class _ListPostsPageState extends State<ListPostsPage> {
  @override
  Widget build(BuildContext context) {
    final itemScrollController = ItemScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController.scrollTo(
        index: context.read<ProfileCubit>().state.mediaIndex,
        duration: const Duration(milliseconds: 1),
        curve: Curves.easeInOut,
      );
    });

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          var cubit = context.read<ProfileCubit>();
          return ScrollablePositionedList.builder(
            itemCount: cubit.state.userPosts.length,
            itemScrollController: itemScrollController,
            itemBuilder: (context, index) => PostWidget(post: cubit.state.userPosts[index]),
          );
        },
      ),
    );
  }
}

