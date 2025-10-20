part of 'story_bloc.dart';

abstract class StoryEvent {}

class LoadDataEvent extends StoryEvent {
  final AssetEntity asset;
  LoadDataEvent(this.asset);
}

class SetMediaTypeEvent extends StoryEvent {
  final String mediaType;
  SetMediaTypeEvent(this.mediaType);
}

class GetStoryMediaFromCameraEvent extends StoryEvent {
  final File file;
  GetStoryMediaFromCameraEvent(this.file);
}

class SetStoryMediaEvent extends StoryEvent {
  final Uint8List bytes;
  SetStoryMediaEvent(this.bytes);
}

class SaveImageChangeEvent extends StoryEvent {
  final Uint8List imageBytes;
  SaveImageChangeEvent(this.imageBytes);
}

class SaveChangeEvent extends StoryEvent {
  final String filePath;
  SaveChangeEvent(this.filePath);
}

class CreateStoryEvent extends StoryEvent {
  final File file;
  final DateTime expiresAt;
  final String visibility;
  CreateStoryEvent({required this.file, required this.expiresAt, required this.visibility});
}