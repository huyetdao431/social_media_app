part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetUserStoryEvent extends HomeEvent{
  final String userId;
  final int? limit;
  final int? offset;
  GetUserStoryEvent({required this.userId, this.limit, this.offset});
}

class GetCurrentStoryEvent extends HomeEvent{
  final int? limit;
  final int? offset;
  GetCurrentStoryEvent({this.limit, this.offset});
}

class MarkUserStoriesWatchedEvent extends HomeEvent {
  final String userId;
  MarkUserStoriesWatchedEvent({required this.userId});
}