import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/utils/crop_aspect_ratios.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';

class EditImageScreen extends StatelessWidget {
  static const String route = 'EditImageScreen';

  const EditImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: Page());
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  bool isReCrop = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if(state.loadStatus == LoadStatus.done) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return cubit.state.loadStatus == LoadStatus.loading
            ? Center(child: CircularProgressIndicator())
            : ProImageEditor.file(
          cubit.state.assets[cubit.state.selectedIndex],
          callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (result) async{
                final croppedImage = await cubit.cropImage(result);
                await cubit.saveImage(croppedImage);
              }
          ),
          configs: ProImageEditorConfigs(
            theme: ThemeData.dark(),
            textEditor: TextEditorConfigs(enabled: true),
            stickerEditor: StickerEditorConfigs(
              enabled: true,
              builder: (addSticker, scrollController) {
                return _StickerMediaGrid(addSticker: addSticker, controller: scrollController);
              },
            ),

            filterEditor: FilterEditorConfigs(enabled: true),
            tuneEditor: TuneEditorConfigs(enabled: true),
            cropRotateEditor: CropRotateEditorConfigs(
              enabled: true,
              initAspectRatio:
              cubit.state.aspectRatio == 1
                  ? CropAspectRatios.ratio1_1
                  : CropAspectRatios.ratio3_4,
              showAspectRatioButton: false,
              style: CropRotateEditorStyle(cropCornerThickness: 0),
              maxWidthFactor: 1.0,
            ),
            paintEditor: PaintEditorConfigs(enabled: false),
            emojiEditor: EmojiEditorConfigs(enabled: false),
            blurEditor: BlurEditorConfigs(enabled: false),
          ),
        );
      },
    );
  }
}

class _StickerMediaGrid extends StatefulWidget {
  final Function(WidgetLayer) addSticker;
  final ScrollController controller;

  const _StickerMediaGrid({
    required this.addSticker,
    required this.controller,
  });

  @override
  State<_StickerMediaGrid> createState() => _StickerMediaGridState();
}

class _StickerMediaGridState extends State<_StickerMediaGrid> {
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

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    _album = albums.first;
    _loadMore();
  }

  void _onScroll() {
    if (widget.controller.position.pixels >=
        widget.controller.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_album == null) return;
    setState(() => _isLoading = true);

    final newPhotos = await _album!.getAssetListPaged(
      page: _page,
      size: _pageSize,
    );

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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 4,
      ),
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
                widget.addSticker(
                  WidgetLayer(widget: Image.memory(bytes)),
                );
              },
              child: Image.memory(snapshotThumb.data!, fit: BoxFit.cover),
            );
          },
        );
      },
    );
  }
}
