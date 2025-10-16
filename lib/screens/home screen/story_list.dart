import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/screens/home%20screen/story_avatar.dart';
import 'package:social_media_app/screens/home%20screen/suggestion_tile.dart';
import '../../cubit/home_bloc/home_bloc.dart';
import '../../cubit/main_cubit/main_cubit.dart';
import '../add_story_screen/add_story_screen.dart';
import '../story_screen/story_screen.dart';

class StoryList extends StatefulWidget {
  const StoryList({super.key});

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  @override
  void initState() {
    super.initState();
    final homeBloc = context.read<HomeBloc>();
    final mainCubit = context.read<MainCubit>();
    homeBloc.add(GetCurrentStoryEvent());
    homeBloc.add(GetUserStoryEvent(userId: mainCubit.state.profile!.id));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<MainCubit>().state.profile!.id;
    final currentUserAvatar = context.read<MainCubit>().state.profile!.avatarUrl ?? '';

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final mergedStories = {currentUserId: state.userStories, ...state.currentStory};

        final userIds = mergedStories.keys.toList();

        return SizedBox(
          height: 100,
          width: double.infinity,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: userIds.length + 1,
            itemBuilder: (ctx, idx) {
              if (idx == 0) {
                final hasMyStories = state.userStories.isNotEmpty;
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (hasMyStories) {
                          Navigator.pushNamed(
                            context,
                            StoryScreen.route,
                            arguments: {'stories': mergedStories, 'startUserId': currentUserId, 'startStoryIndex': idx},
                          );
                          context.read<HomeBloc>().add(MarkUserStoriesWatchedEvent(userId: currentUserId));
                        } else {
                          Navigator.pushNamed(context, AddStoryScreen.route);
                        }
                      },
                      child: StoryAvatar(size: 72, avatarUrl: currentUserAvatar, stories: state.userStories, isCurrentUser: true, username: 'Tin của bạn'),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 26,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AddStoryScreen.route),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(width: 1.5, color: Colors.black)),
                          child: const Icon(Icons.add, size: 21, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (idx < userIds.length) {
                final userId = userIds[idx];
                if (userId == currentUserId) return const SizedBox.shrink();

                final stories = mergedStories[userId] ?? [];
                final firstStory = stories.isNotEmpty ? stories.first : null;
                final avatarUrl = firstStory?.avatarUrl ?? '';
                final username = firstStory?.username ?? 'Người dùng';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, StoryScreen.route, arguments: {'stories': mergedStories, 'startUserId': currentUserId, 'startStoryIndex': idx});
                    context.read<HomeBloc>().add(MarkUserStoriesWatchedEvent(userId: userId));
                  },
                  child: StoryAvatar(size: 72, avatarUrl: avatarUrl, stories: stories, username: username),
                );
              }

              return const SuggestionTile(avatarUrl: '', username: 'Gợi ý', userId: '');
            },
          ),
        );
      },
    );
  }
}
