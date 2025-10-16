import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/models/profile/profile.dart';
import 'package:social_media_app/models/story.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Api api;
  HomeBloc(this.api) : super(HomeState.init()) {
    on<GetUserStoryEvent>(_onGetUserStory);
    on<GetCurrentStoryEvent>(_onGetCurrentStory);
    on<MarkUserStoriesWatchedEvent>(_onMarkUserStoriesWatched);
  }

  Future<void> _onGetUserStory(GetUserStoryEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loadStoryStatus: LoadStatus.loading));
    try {
      final userStory = await api.getStoriesByUser(userId: event.userId);
      emit(state.copyWith(loadStoryStatus: LoadStatus.done, userStories: userStory));
    } catch(e) {
      emit(state.copyWith(loadStoryStatus: LoadStatus.done, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _onGetCurrentStory(GetCurrentStoryEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loadStoryStatus: LoadStatus.loading));
    try {
      final stories = await api.getFeedStories();
      final currentStories = <String, List<Story>>{};
      for(var story in stories) {
        currentStories.putIfAbsent(story.userId, () => []);
        currentStories[story.userId]!.add(story);
      }
      emit(state.copyWith(loadStoryStatus: LoadStatus.done, currentStory: currentStories));
    } catch(e) {
      emit(state.copyWith(loadStoryStatus: LoadStatus.done, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

  Future<void> _onMarkUserStoriesWatched(MarkUserStoriesWatchedEvent event, Emitter<HomeState> emit) async {
    try {
      final newMap = Map<String, List<Story>>.from(state.currentStory);
      if (newMap.containsKey(event.userId)) {
        final updated = newMap[event.userId]!.map((s) {
          return s.copyWith(isViewed: true);
        }).toList();
        newMap[event.userId] = updated;
      }

      final newUserStories = state.userStories.map((s) {
        if (s.userId == event.userId) {
          return s.copyWith(isViewed: true);
        }
        return s;
      }).toList();

      emit(state.copyWith(currentStory: newMap, userStories: newUserStories));
    } catch (e) {
      // silent fail hoặc emit lỗi tuỳ bạn
    }
  }

}
