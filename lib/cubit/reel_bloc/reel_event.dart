part of 'reel_bloc.dart';

abstract class ReelEvent {}

class CreateReelEvent extends ReelEvent {
  final File file;
  final String? content;
  final bool? isPublic;
  final File thumbImage;
  CreateReelEvent({required this.file, this.content, this.isPublic, required this.thumbImage});
}

class GetReelsByUserEvent extends ReelEvent {
  final String userId;
  final int? limit;
  final int? offset;
  GetReelsByUserEvent({required this.userId, this.limit, this.offset});
}

class GetFeedReelsEvent extends ReelEvent {
  final int? limit;
  final int? offset;
  GetFeedReelsEvent({this.limit, this.offset});
}

class LoadDataEvent extends ReelEvent {
  final AssetEntity asset;
  LoadDataEvent({required this.asset});
}

class SaveChangeEvent extends ReelEvent {
  final File file;
  SaveChangeEvent({required this.file});
}