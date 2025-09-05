import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class StickerMediaGrid extends StatefulWidget {
  final Function(WidgetLayer) addSticker;
  final ScrollController controller;

  const StickerMediaGrid({super.key, required this.addSticker, required this.controller});

  @override
  State<StickerMediaGrid> createState() => _StickerMediaGridState();
}

class _StickerMediaGridState extends State<StickerMediaGrid> {
  final List<AssetEntity> _photos = [];
  bool _isLoading = false;
  int _page = 0;
  final int _pageSize = 40;
  AssetPathEntity? _album;

  @override
  void initState() {
    super.initState();
    _initAlbum();
    widget.controller.addListener(_onScroll);
  }

  Future<void> _initAlbum() async {
    final ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image, onlyAll: true);
    _album = albums.first;
    _loadMore();
  }

  void _onScroll() {
    if (widget.controller.position.pixels >= widget.controller.position.maxScrollExtent - 200 && !_isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_album == null) return;
    setState(() => _isLoading = true);

    final newPhotos = await _album!.getAssetListPaged(page: _page, size: _pageSize);

    setState(() {
      _photos.addAll(newPhotos);
      _page++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      controller: widget.controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 4),
      itemCount: _photos.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _photos.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final asset = _photos[index];
        return FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
          builder: (context, snapshotThumb) {
            if (!snapshotThumb.hasData) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () async {
                final bytes = await asset.originBytes;
                if (bytes == null) return;
                widget.addSticker(WidgetLayer(widget: Image.memory(bytes)));
              },
              child: Image.memory(snapshotThumb.data!, fit: BoxFit.cover),
            );
          },
        );
      },
    );
  }
}
