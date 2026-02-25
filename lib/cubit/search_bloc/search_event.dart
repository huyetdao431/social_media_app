part of 'search_bloc.dart';

abstract class SearchEvent {}

class SearchProfileEvent extends SearchEvent {
  final String searchText;
  final int? limit;
  final double? lastScore;
  final String? lastId;

  SearchProfileEvent({required this.searchText, this.limit, this.lastScore, this.lastId});
}

class SearchPostEvent extends SearchEvent {
  final String searchText;
  final int? limit;
  final double? lastScore;
  final String? lastId;

  SearchPostEvent({required this.searchText, this.limit, this.lastScore, this.lastId});
}

class SearchReelEvent extends SearchEvent {
  final String searchText;
  final int? limit;
  final double? lastScore;
  final String? lastId;

  SearchReelEvent({required this.searchText, this.limit, this.lastScore, this.lastId});
}

class SearchAllEvent extends SearchEvent {
  final String searchText;
  SearchAllEvent({required this.searchText});
}

class SwitchPageEvent extends SearchEvent {
  final bool isSearchPage;
  SwitchPageEvent({required this.isSearchPage});
}
