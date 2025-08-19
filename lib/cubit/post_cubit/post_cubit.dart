import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostState.init());

  void loadSelectedAssets(List<AssetEntity> assets) {
    emit(state.copyWith(selectedAssets: assets));
  }

  // Future<void> applyCrop(List<Uint8List> selectedAssets) async {
  //   emit(state.copyWith(loadStatus: LoadStatus.loading));
  //   try {
  //     final croppedImages = await Future.wait(
  //       selectedAssets.map((bytes) => autoCropImage(bytes)),
  //     );
  //     emit(state.copyWith(loadStatus: LoadStatus.done, editedAssets: croppedImages));
  //   } catch (e) {
  //     emit(state.copyWith(loadStatus: LoadStatus.error));
  //   }
  // }
  //
  // Future<Uint8List> autoCropImage(Uint8List originalByte) async {
  //   final image = img.decodeImage(originalByte)!;
  //
  //   int x = 0;
  //   int y = 0;
  //   int width = image.width;
  //   int height = image.height;
  //   double imageRatio = image.width / image.height;
  //
  //   if (imageRatio > state.aspectRatio) {
  //     height = image.height;
  //     width = (height * state.aspectRatio).toInt();
  //     x = (image.width - width) ~/ 2;
  //     y = 0;
  //   } else {
  //     width = image.width;
  //     height = (width / state.aspectRatio).toInt();
  //     x = 0;
  //     y = (image.height - height) ~/ 2;
  //   }
  //
  //   final cropped = img.copyCrop(
  //     image,
  //     x: x,
  //     y: y,
  //     width: width,
  //     height: height,
  //   );
  //
  //   return Uint8List.fromList(img.encodeJpg(cropped));
  // }

  void updateAspectRatio(double aspectRatio) {
    emit(state.copyWith(aspectRatio: aspectRatio));
  }

  void removeAsset() {
    var newAssets = state.selectedAssets;
    newAssets.removeAt(state.selectedIndex);
    emit(state.copyWith(selectedAssets: newAssets));
  }

  void setIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  // void updateEditedImage(Uint8List editedImage) {
  //   var cpy = state.editedAssets;
  //   cpy[state.selectedIndex] = editedImage;
  //   emit(state.copyWith(editedAssets: cpy));
  // }
}
