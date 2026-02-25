import 'package:bloc/bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/models/profile/profile.dart';
import 'package:social_media_app/models/reel.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

import '../../models/post.dart';

part 'search_event.dart';

part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  Api api;

  SearchBloc(this.api) : super(SearchState.init()) {
    on<SearchProfileEvent>(_onSearchProfile);
    on<SearchPostEvent>(_onSearchPost);
    on<SearchReelEvent>(_onSearchReel);
    on<SearchAllEvent>(_onSearchAll);
    on<SwitchPageEvent>(_onSwitchPage);
  }

  Future<void> _onSearchProfile(SearchProfileEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(loadProfileStatus: LoadStatus.loading));

    try {
      final result = await api.searchProfiles(query: event.searchText, limit: event.limit ?? 20, lastScore: event.lastScore, lastId: event.lastId);

      final currentProfiles = List<Profile>.from((state.searchProfileInfo['profiles'] ?? []) as List);

      final allProfiles = [...currentProfiles, ...result];

      final lastProfile = result.isNotEmpty ? result.last : null;

      final newSearchProfileInfo = {'profiles': allProfiles, 'limit': event.limit, 'lastId': lastProfile?.id, 'lastScore': allProfiles.length};

      emit(state.copyWith(loadProfileStatus: LoadStatus.done, searchProfileInfo: newSearchProfileInfo));
    } catch (e) {
      emit(state.copyWith(loadProfileStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchPost(SearchPostEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(loadPostStatus: LoadStatus.loading));

    try {
      final result = await api.searchPosts(query: event.searchText, limit: event.limit ?? 20, lastScore: event.lastScore, lastId: event.lastId);

      final currentPosts = List<Post>.from((state.searchPostInfo['posts'] ?? []) as List);

      final allPosts = [...currentPosts, ...result];

      final lastPost = result.isNotEmpty ? result.last : null;

      final newSearchPostInfo = {'posts': allPosts, 'limit': event.limit, 'lastId': lastPost?.id, 'lastScore': allPosts.length};

      emit(state.copyWith(loadPostStatus: LoadStatus.done, searchPostInfo: newSearchPostInfo));
    } catch (e) {
      emit(state.copyWith(loadPostStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchReel(SearchReelEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(loadReelStatus: LoadStatus.loading));

    try {
      final result = await api.searchReels(query: event.searchText, limit: event.limit ?? 20, lastScore: event.lastScore, lastId: event.lastId);

      final currentReels = List<Reel>.from((state.searchReelInfo['reels'] ?? []) as List);

      final allReels = [...currentReels, ...result];

      final lastReel = result.isNotEmpty ? result.last : null;

      final newSearchReelInfo = {'reels': allReels, 'limit': event.limit, 'lastId': lastReel?.reelId, 'lastScore': allReels.length};

      emit(state.copyWith(loadReelStatus: LoadStatus.done, searchReelInfo: newSearchReelInfo));
    } catch (e) {
      emit(state.copyWith(loadReelStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchAll(SearchAllEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      add(SearchProfileEvent(searchText: event.searchText, limit: 6));
      add(SearchPostEvent(searchText: event.searchText, limit: 6));
      add(SearchReelEvent(searchText: event.searchText, limit: 6));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
    }
  }

  void _onSwitchPage(SwitchPageEvent event, Emitter<SearchState> emit) {
    emit(state.copyWith(isSearchPage: event.isSearchPage));
  }
}
