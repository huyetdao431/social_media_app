import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/models/story.dart';
import 'package:social_media_app/services/repositories/api/api.dart';
import 'dart:typed_data';

import '../../commons/enums/load_status.dart';

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  Api api;
  StoryBloc(this.api) : super(StoryState.init()) {
    on<LoadDataEvent>(_onLoadData);
    on<SetMediaTypeEvent>(_onSetMediaType);
    on<GetStoryMediaFromCameraEvent>(_onGetStoryMediaFromCamera);
    on<SetStoryMediaEvent>(_onSetStoryMedia);
    on<SaveImageChangeEvent>(_onSaveImageChange);
    on<SaveChangeEvent>(_onSaveChange);
    on<CreateStoryEvent>(_onCreateStory);
  }

  Future<void> _onLoadData(LoadDataEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = await event.asset.file;
      emit(state.copyWith(storyMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void _onSetMediaType(SetMediaTypeEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(mediaType: event.mediaType));
  }

  void _onGetStoryMediaFromCamera(GetStoryMediaFromCameraEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(storyMedia: event.file));
  }

  Future<void> _onSetStoryMedia(SetStoryMediaEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(event.bytes);
      emit(state.copyWith(storyMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future<void> _onSaveImageChange(SaveImageChangeEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.png");
      await file.writeAsBytes(event.imageBytes);
      emit(state.copyWith(storyMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
      throw Exception(e);
    }
  }

  void _onSaveChange(SaveChangeEvent event, Emitter<StoryState> emit) {
    emit(state.copyWith(storyMedia: File(event.filePath)));
  }

  Future<void> _onCreateStory(CreateStoryEvent event, Emitter<StoryState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      Story story;
      if(event.visibility != null) {
        story = await api.createStory(file: event.file, expiresAt: event.expiresAt);
      } else {
        story = await api.createStory(file: event.file, expiresAt: event.expiresAt, visibility: event.visibility.toString());
      }
      emit(state.copyWith(loadStatus: LoadStatus.done, currentStory: story));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error, errorMessage: e.toString()));
      throw Exception(e);
    }
  }

}
