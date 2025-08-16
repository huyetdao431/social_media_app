import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostState.init());

  Future<void> loadSelectedAssets(List<AssetEntity> assets) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      List<Uint8List> results = [];
      for (var asset in assets) {
        final bytes = await asset.originBytes;
        results.add(bytes!);
      }
      emit(
        state.copyWith(selectedAssets: results, loadStatus: LoadStatus.done),
      );
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void removeAsset() {
    var newAssets = state.selectedAssets;
    newAssets.removeAt(state.seletedIndex);
    emit(state.copyWith(selectedAssets: newAssets));
  }

  void setIndex(int index) {
    emit(state.copyWith(seletedIndex: index));
  }
}
