import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/commons/widgets/video_trimmer_screen.dart';
import 'package:social_media_app/cubit/reel_cubit/reel_cubit.dart';
import 'package:social_media_app/screens/add_reel_screen/edit_reel_screen.dart';
import 'package:social_media_app/utils/dialogs.dart';
import 'package:social_media_app/utils/get_video_duration.dart';

import '../../materials/app_colors.dart';
import '../../commons/widgets/camera_screen.dart';

class AddReelScreen extends StatelessWidget {
  static const String route = 'AddReelScreen';

  const AddReelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ReelCubit(), child: Theme(data: ThemeData.dark(), child: Page()));
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
        title: Text('Create a new Story'),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  height: 100,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.textMutedLight),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_box_outlined), Text('Example')])),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  height: 100,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.textMutedLight),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.library_music), Text('Music')])),
                ),
              ),
            ],
          ),
          Expanded(child: GalleryWidget()),
        ],
      ),
    );
  }
}

class GalleryWidget extends StatefulWidget {
  const GalleryWidget({super.key});

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<GalleryWidget> {
  final List<AssetEntity> _mediaList = [];
  List<Map<AssetPathEntity, int>> _albums = [];
  int selectedIndex = 0;
  AssetPathEntity? _currentAlbum;

  bool _loading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  final int _pageSize = 60;
  final ScrollController _scrollController = ScrollController();

  /// cache thumbnail để tránh load lại nhiều lần
  final Map<String, Uint8List?> _thumbCache = {};

  @override
  void initState() {
    super.initState();
    _initPermission();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initPermission() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      PhotoManager.openSetting();
      return;
    }
    await _loadAlbums();
    await _loadInitialMedia();
    setState(() => _loading = false);
  }

  Future<void> _loadAlbums() async {
    final albums = await PhotoManager.getAssetPathList(type: RequestType.video, onlyAll: false);
    final List<Map<AssetPathEntity, int>> result = [];
    for (var album in albums) {
      final count = await album.assetCountAsync;
      result.add({album: count});
    }
    _albums = result;
    _currentAlbum = albums.isNotEmpty ? albums.first : null;
  }

  Future<void> _loadInitialMedia() async {
    _page = 0;
    _mediaList.clear();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentAlbum == null) return;
    setState(() => _isLoadingMore = true);

    final newMedia = await _currentAlbum!.getAssetListPaged(page: _page, size: _pageSize);

    setState(() {
      _mediaList.addAll(newMedia);
      _page++;
      _isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<Uint8List?> _getThumb(AssetEntity asset) async {
    if (_thumbCache.containsKey(asset.id)) return _thumbCache[asset.id]; // lấy từ cache
    final data = await asset.thumbnailDataWithSize(const ThumbnailSize(300, 300));
    _thumbCache[asset.id] = data; // lưu vào cache
    return data;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelCubit, ReelState>(
      builder: (context, state) {
        var cubit = context.read<ReelCubit>();
        return _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 9 / 16, // tỉ lệ 9:16
                ),
                itemCount: _mediaList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // cell đầu tiên mở Camera
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(CameraScreen.route) as Map<String, dynamic>;
                        final file = result['file'] as File;
                        final mediaType = result['mediaType'] as String;
                        if (context.mounted) {
                          context.read<ReelCubit>().setMediaType(mediaType);
                          context.read<ReelCubit>().saveFileMedia(file);
                          Navigator.of(context).pushNamed(EditReelScreen.route, arguments: {'cubit': context.read<ReelCubit>()});
                        }
                      },
                      child: Container(color: Colors.black26, child: const Icon(Icons.camera_alt, size: 40)),
                    );
                  }
                  final asset = _mediaList[index - 1];
                  return FutureBuilder<Uint8List?>(
                    future: _getThumb(asset),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(color: Colors.grey[300]);
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              //TODO: go to edit reel screen
                              final file = await asset.file;
                              final duration = await getVideoDuration(file!.path);
                              if(duration > 60) {
                                await showNotificationDialog(context, message: 'Video must not longer than 60 seconds');
                                final result = await Navigator.of(context).pushNamed(VideoTrimScreen.route, arguments: {'file': file}) as File;
                                cubit.saveFileMedia(result);
                              } else {
                                cubit.saveFileMedia(file);
                              }
                              Navigator.of(context).pushNamed(EditReelScreen.route, arguments: {'cubit': cubit});
                            },
                            child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                          ),

                          // overlay icon + thời lượng cho video
                          if (asset.type == AssetType.video)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              left: 4,
                              child: Text(
                                _formatDuration(asset.videoDuration),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
