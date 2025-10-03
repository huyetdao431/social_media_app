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

  /// Load files (File) cho các selectedAssets (AssetEntity -> File)
  Future<void> loadData() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final assets = <Map<String, dynamic>>[];
      for (final e in state.selectedAssets) {
        try {
          final file = await e.file;
          if (file != null) {
            assets.add({
              'file': file,
              'type': e.type == AssetType.image ? 'image' : 'video',
            });
          }
        } catch (inner) {
          // bỏ qua asset không load được, tiếp tục các asset khác
        }
      }
      emit(state.copyWith(assets: List<Map<String, dynamic>>.from(assets), loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  /// Thêm 1 asset (thường dùng khi chụp từ camera) -> thêm vào assets (không ép thành AssetEntity)
  void addToAsset(Map<String, dynamic> asset) {
    final updatedAssets = List<Map<String, dynamic>>.from(state.assets)
      ..add(asset);
    emit(state.copyWith(assets: updatedAssets));
  }

  /// Thêm AssetEntity vào selectedAssets (clone list) và set selectedIndex về vị trí mới
  void addToSelectedAssets(AssetEntity asset) {
    final updatedSelected = List<AssetEntity>.from(state.selectedAssets)
      ..add(asset);
    emit(state.copyWith(selectedAssets: updatedSelected, selectedIndex: updatedSelected.length - 1));
  }

  /// Toggle multi-select: nếu đã tồn tại -> remove, nếu chưa -> add
  void toggleMultiSelect(AssetEntity asset) {
    final list = List<AssetEntity>.from(state.selectedAssets);
    final idx = list.indexOf(asset);

    if (idx >= 0) {
      // asset đã tồn tại trong list
      if (idx == state.selectedIndex) {
        // chỉ xóa khi idx bằng selectedIndex hiện tại
        final newList = List<AssetEntity>.from(list)
          ..removeAt(idx);
        int newIndex;
        if (newList.isEmpty) {
          newIndex = 0;
        } else {
          // nếu idx đã là cuối cùng thì giảm 1, ngược lại giữ idx (vì các phần tử sau dịch trái)
          newIndex = (idx >= newList.length) ? newList.length - 1 : idx;
        }
        emit(state.copyWith(selectedAssets: newList, selectedIndex: newIndex));
      } else {
        // asset tồn tại nhưng không phải đang được preview -> chuyển preview sang asset này
        emit(state.copyWith(selectedIndex: idx));
      }
    } else {
      // asset chưa tồn tại -> thêm và set index tới vị trí mới
      final newList = List<AssetEntity>.from(list)
        ..add(asset);
      emit(state.copyWith(selectedAssets: newList, selectedIndex: newList.length - 1));
    }
  }

  void toggleMultiSelect2(AssetEntity asset) {
    final list = List<AssetEntity>.from(state.selectedAssets);
    final idx = list.indexOf(asset);
    if (idx >= 0) {
      list.removeAt(idx);
      final newIndex = list.isEmpty ? 0 : state.selectedIndex.clamp(0, list.length - 1);
      emit(state.copyWith(selectedAssets: list, selectedIndex: newIndex));
    } else {
      list.add(asset);
      emit(state.copyWith(selectedAssets: list, selectedIndex: list.length - 1));
    }
  }


  /// Single-select behaviour: nếu đã có -> setIndex, nếu chưa -> thay thế selection bằng asset
  void selectSingle(AssetEntity asset) {
    final list = List<AssetEntity>.from(state.selectedAssets);
    final idx = list.indexOf(asset);
    if (idx >= 0) {
      emit(state.copyWith(selectedIndex: idx));
      return;
    }
    // thay thế selection
    final newList = <AssetEntity>[asset];
    emit(state.copyWith(selectedAssets: newList, selectedIndex: 0));
  }

  /// Load path của video đang chọn (an toàn)
  Future<String> loadVideo() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      if (state.assets.isEmpty) {
        emit(state.copyWith(loadStatus: LoadStatus.error));
        return '';
      }
      final idx = state.selectedIndex.clamp(0, state.assets.length - 1);
      final fileMap = state.assets[idx];
      if (fileMap['type'] != 'video') {
        emit(state.copyWith(loadStatus: LoadStatus.error));
        return '';
      }
      final file = fileMap['file'] as File?;
      if (file == null) {
        emit(state.copyWith(loadStatus: LoadStatus.error));
        return '';
      }
      final filePath = file.path;
      emit(state.copyWith(loadStatus: LoadStatus.done));
      return filePath;
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
      return '';
    }
  }

  /// Load bytes của image đang chọn
  Future<Uint8List?> loadImage() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      if (state.assets.isEmpty) {
        emit(state.copyWith(loadStatus: LoadStatus.error));
        return null;
      }
      final idx = state.selectedIndex.clamp(0, state.assets.length - 1);
      final fileMap = state.assets[idx];
      if (fileMap['type'] != 'image') {
        emit(state.copyWith(loadStatus: LoadStatus.error));
        return null;
      }
      final file = fileMap['file'] as File?;
      if (file == null) {
        emit(state.copyWith(loadStatus: LoadStatus.error));
        return null;
      }
      final bytes = await file.readAsBytes();
      emit(state.copyWith(loadStatus: LoadStatus.done));
      return bytes;
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
      return null;
    }
  }

  /// Crop image theo aspect ratio hiện tại (trả về bytes jpg)
  Future<Uint8List> cropImage(Uint8List assetBytes) async {
    final img.Image? original = img.decodeImage(assetBytes);
    if (original == null) throw Exception('Không đọc được ảnh');
    int x = 0,
        y = 0,
        wid = original.width,
        hei = original.height;
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
    final img.Image cropped = img.copyCrop(original, x: x, y: y, width: wid, height: hei);
    return Uint8List.fromList(img.encodeJpg(cropped));
  }

  /// Lưu ảnh đã chỉnh sửa: tạo file tạm, thay thế trong assets (clone), đánh dấu edited index
  Future<void> saveImage(Uint8List editedImage) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final tmpDir = await getTemporaryDirectory();
      final file = File('${tmpDir.path}/edited_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(editedImage);

      final idx = state.selectedIndex.clamp(0, state.assets.length - 1);
      final newAssets = List<Map<String, dynamic>>.from(state.assets);
      if (idx < 0 || idx > newAssets.length) {
        // nếu assets rỗng thì thêm mới
        newAssets.add({'file': file, 'type': 'image'});
      } else {
        newAssets[idx] = {'file': file, 'type': 'image'};
      }

      final editedIndex = List<int>.from(state.editedAssetIndex)
        ..add(idx);
      emit(state.copyWith(loadStatus: LoadStatus.done, assets: newAssets, editedAssetIndex: editedIndex));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  /// Lưu video đã chỉnh sửa (hoặc video mới) vào assets
  Future<void> saveVideo(String videoPath) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      final file = File(videoPath);
      final idx = state.selectedIndex.clamp(0, state.assets.length - 1);
      final newAssets = List<Map<String, dynamic>>.from(state.assets);
      if (idx < 0 || idx > newAssets.length) {
        newAssets.add({'file': file, 'type': 'video'});
      } else {
        newAssets[idx] = {'file': file, 'type': 'video'};
      }

      final editedIndex = List<int>.from(state.editedAssetIndex)
        ..add(idx);
      emit(state.copyWith(loadStatus: LoadStatus.done, assets: newAssets, editedAssetIndex: editedIndex));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  /// Lưu tất cả assets hiện đang có vào gallery (image/video)
  Future<void> saveToGallery() async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    try {
      for (final fileMap in state.assets) {
        final type = fileMap['type'] as String?;
        final file = fileMap['file'] as File?;
        if (file == null || !(await file.exists())) continue;
        if (type == 'image') {
          await Helper.saveImageToGallery(file);
        } else {
          await Helper.saveVideoToGallery(file);
        }
      }
      emit(state.copyWith(loadStatus: LoadStatus.done));
    } catch (e) {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void updateAspectRatio(double aspectRatio) {
    emit(state.copyWith(aspectRatio: aspectRatio));
  }

  /// Remove asset ở vị trí selectedIndex (an toàn, cập nhật selectedIndex)
  void removeAsset() {
    final idx = state.selectedIndex;
    if (state.assets.isEmpty) return;
    if (idx < 0 || idx >= state.assets.length) return;

    final newAssets = List<Map<String, dynamic>>.from(state.assets)
      ..removeAt(idx);

    // Nếu có selectedAssets tương ứng (cố gắng xóa cùng index nếu tồn tại)
    final newSelectedAssets = List<AssetEntity>.from(state.selectedAssets);
    if (idx >= 0 && idx < newSelectedAssets.length) {
      newSelectedAssets.removeAt(idx);
    }

    final newIndex = newSelectedAssets.isEmpty ? 0 : state.selectedIndex.clamp(0, newSelectedAssets.length - 1);
    emit(state.copyWith(assets: newAssets, selectedAssets: newSelectedAssets, selectedIndex: newIndex));
  }

  /// Remove one selected asset (chỉ trong selectedAssets)
  void removeSelectedAssets() {
    final idx = state.selectedIndex;
    if (state.selectedAssets.isEmpty) return;
    if (idx < 0 || idx >= state.selectedAssets.length) return;

    final newSelected = List<AssetEntity>.from(state.selectedAssets)
      ..removeAt(idx);
    final newIndex = newSelected.isEmpty ? 0 : state.selectedIndex.clamp(0, newSelected.length - 1);
    emit(state.copyWith(selectedAssets: newSelected, selectedIndex: newIndex));
  }

  /// Clear all selected assets
  void clearSelectedAssets() {
    emit(state.copyWith(selectedAssets: <AssetEntity>[], selectedIndex: 0));
  }

  /// alias cho UI mới
  void clearSelected() => clearSelectedAssets();

  void setIndex(int index) {
    final newIndex = state.selectedAssets.isEmpty ? 0 : index.clamp(0, state.selectedAssets.length - 1);
    emit(state.copyWith(selectedIndex: newIndex));
  }

  /// Xoá các file đã edit (chỉ xoá các file đánh dấu trong editedAssetIndex) — an toàn
  Future<void> deleteEditedAssets() async {
    try {
      final edited = List<int>.from(state.editedAssetIndex);
      for (final idx in edited) {
        if (idx >= 0 && idx < state.assets.length) {
          final fileMap = state.assets[idx];
          final f = fileMap['file'] as File?;
          if (f != null && await f.exists()) {
            try {
              await f.delete();
            } catch (_) {
              // ignore delete errors for specific files
            }
          }
        }
      }
      // reset editedAssetIndex sau khi xoá
      emit(state.copyWith(editedAssetIndex: <int>[]));
    } catch (e) {
      // không emit throw để không crash cubit - caller có thể muốn xử lý
    }
  }
}
