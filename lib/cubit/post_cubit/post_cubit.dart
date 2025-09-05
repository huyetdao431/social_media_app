import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:image/image.dart' as img;
import 'package:social_media_app/commons/helpers/helper.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostState.init());

  Future<void> loadData(List<AssetEntity> selectedAssets) async{
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final assets = (await Future.wait(
        selectedAssets.map((e) => e.file),
      )).whereType<File>().toList();
      emit(state.copyWith(selectedAssets: selectedAssets, assets: assets, loadStatus: LoadStatus.done));
    } catch(e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future<String> loadVideo() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = state.assets[state.selectedIndex];
      final filePath = file.path;
      emit(state.copyWith(loadStatus: LoadStatus.done));
      return filePath;
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
    return '';
  }

  Future<Uint8List?> loadImage() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = state.assets[state.selectedIndex];
      final image = await file.readAsBytes();
      // final croppedImage = await cropImage(image);
      emit(state.copyWith(loadStatus: LoadStatus.done));
      return image;
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.done));
    }
    return null;
  }

  Future<Uint8List> cropImage(Uint8List assetBytes) async {
    img.Image? original = img.decodeImage(assetBytes);
    if (original == null) throw Exception('Khong doc duoc anh');
    int x, y, wid, hei;
    if (original.width < original.height) {
      x = 0;
      wid = original.width;
      if (state.aspectRatio == 1) {
        hei = original.width;
        y = (original.height - original.width) ~/ 2;
      } else {
        hei = (original.width * 4 / 3).floor();
        y = (original.height - hei) ~/ 2;
      }
    } else {
      y = 0;
      hei = original.height;
      if (state.aspectRatio == 1) {
        wid = hei;
        x = (original.width - original.height) ~/ 2;
      } else {
        wid = (hei * 0.75).floor();
        x = (original.width - wid) ~/ 2;
      }
    }
    img.Image cropped = img.copyCrop(original, x: x, y: y, width: wid, height: hei);
    return Uint8List.fromList(img.encodeJpg(cropped));
  }

  Future<void> saveImage(Uint8List editedImage) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = File('${(await getTemporaryDirectory()).path}/edited_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(editedImage);
      var assets = state.assets;
      assets[state.selectedIndex] = file;
      var editedAssetIndex = List<int>.from(state.editedAssetIndex);
      editedAssetIndex.add(state.selectedIndex);
      emit(state.copyWith(loadStatus: LoadStatus.done, assets: assets, editedAssetIndex: editedAssetIndex));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future<void> saveVideo(String videoPath) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = File(videoPath);
      var assets = state.assets;
      assets[state.selectedIndex] = file;
      var editedAssetIndex = List<int>.from(state.editedAssetIndex);
      editedAssetIndex.add(state.selectedIndex);
      emit(state.copyWith(loadStatus: LoadStatus.done, assets: assets, editedAssetIndex: editedAssetIndex));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future<void> saveToGallery() async{
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      for(int i = 0; i < state.assets.length; i++) {
        if(state.selectedAssets[i].type == AssetType.image) {
          await Helper.saveImageToGallery(state.assets[i]);
        } else {
          await Helper.saveVideoToGallery(state.assets[i]);
        }
      }
    } catch(e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void updateAspectRatio(double aspectRatio) {
    emit(state.copyWith(aspectRatio: aspectRatio));
  }

  void removeAsset() {
    var newAssets = state.assets;
    newAssets.removeAt(state.selectedIndex);
    var newSelectedAssets = state.selectedAssets;
    newSelectedAssets.removeAt(state.selectedIndex);
    emit(state.copyWith(assets: newAssets, selectedAssets: newSelectedAssets));
  }

  void setIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> deleteEditedAssets() async {
    try {
      for(var file in state.assets) {
        if(await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
