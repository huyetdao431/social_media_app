import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../commons/enums/load_status.dart';

part 'reel_state.dart';

class ReelCubit extends Cubit<ReelState> {
  ReelCubit() : super(ReelState.init());

  Future<void> loadData(AssetEntity asset) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = await asset.file;
      emit(state.copyWith(reelMedia: file, loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void saveFileMedia(File file) {
    emit(state.copyWith(reelMedia: file));
  }

  void setMediaType(String mediaType) {
    emit(state.copyWith(mediaType: mediaType));
  }
}
