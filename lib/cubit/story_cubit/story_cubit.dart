import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';

part 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  StoryCubit() : super(StoryState.init());

  Future<void> loadData() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = await state.selectedMedia!.file;
      emit(state.copyWith(storyMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void setSelectedMedia(AssetEntity asset) {
    emit(state.copyWith(selectedMedia: asset));
  }

  Future<void> setStoryMedia(Uint8List bytes) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = File('${(await getTemporaryDirectory()).path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      emit(state.copyWith(storyMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future<void> saveImageChange(Uint8List imageBytes) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.png");
      await file.writeAsBytes(imageBytes);
      emit(state.copyWith(storyMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
      throw Exception(e);
    }
  }

  void saveChange(String filePath) {
    emit(state.copyWith(storyMedia: File(filePath)));
  }
}
