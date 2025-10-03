import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/materials/app_colors.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/screens/add_story_screen/edit_story_screen.dart';

import '../../cubit/story_cubit/story_cubit.dart';
import '../../commons/widgets/camera_screen.dart';

class AddStoryScreen extends StatelessWidget {
  static const String route = 'AddStoryScreen';

  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => StoryCubit(), child: Theme(data: ThemeData.dark(), child: Page()));
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
  String _albumName = "Gần đây";

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
    final albums = await PhotoManager.getAssetPathList(type: RequestType.common, onlyAll: false);
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

  void _chooseAlbum(AssetPathEntity album) async {
    _currentAlbum = album;
    _albumName = album.name.isNotEmpty ? album.name : "Không tên";
    await _loadInitialMedia();
    if (mounted) Navigator.pop(context);
  }

  void _filterBy(RequestType type, String name) async {
    _albumName = name;
    final albums = await PhotoManager.getAssetPathList(type: type, onlyAll: true);
    if (albums.isNotEmpty) {
      _currentAlbum = albums.first;
      await _loadInitialMedia();
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, state) {
        var cubit = context.read<StoryCubit>();
        return _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
              children: [
                // Album picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [TextButton.icon(onPressed: _showAlbumPicker, icon: const Icon(Icons.keyboard_arrow_down), label: Text(_albumName))],
                ),

                // GridView media
                Expanded(
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
                              context.read<StoryCubit>().setMediaType(mediaType);
                              context.read<StoryCubit>().getStoryMediaFromCamera(file);
                              Navigator.of(context).pushNamed(EditStoryScreen.route, arguments: {'cubit': cubit});
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
                                  cubit.setMediaType(asset.type == AssetType.image ? 'image' : 'video');
                                  await cubit.loadData(asset);
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushNamed(EditStoryScreen.route, arguments: {'cubit': cubit});
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
                ),
              ],
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

  void _showAlbumPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (context, scrollController) {
            return Theme(
              data: ThemeData.dark(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),

                  // nút lọc danh mục
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(icon: Icons.collections, label: "Gần đây", onTap: () => _filterBy(RequestType.common, "Gần đây")),
                      _buildFilterButton(icon: Icons.image, label: "Ảnh", onTap: () => _filterBy(RequestType.image, "Ảnh")),
                      _buildFilterButton(icon: Icons.video_collection, label: "Video", onTap: () => _filterBy(RequestType.video, "Video")),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // danh sách album
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 9 / 16,
                      ),
                      itemCount: _albums.length,
                      itemBuilder: (context, index) {
                        final album = _albums[index];
                        final albumEntity = album.keys.first;
                        final count = album.values.first;
                        final albumNameSafe = albumEntity.name.isNotEmpty ? albumEntity.name : "Không tên";

                        return FutureBuilder<List<AssetEntity>>(
                          future: albumEntity.getAssetListRange(start: 0, end: 1),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return _buildAlbumPlaceholder(albumNameSafe, count);
                            }
                            final firstAsset = snapshot.data!.first;
                            return FutureBuilder<Uint8List?>(
                              future: _getThumb(firstAsset), //  dùng cache luôn
                              builder: (context, thumbSnap) {
                                if (!thumbSnap.hasData) {
                                  return _buildAlbumPlaceholder(albumNameSafe, count);
                                }
                                return GestureDetector(
                                  onTap: () async {
                                    _chooseAlbum(albumEntity);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.memory(thumbSnap.data!, fit: BoxFit.cover, width: double.infinity),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(albumNameSafe, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text("$count mục", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 26, backgroundColor: Colors.grey[200], child: Icon(icon, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAlbumPlaceholder(String name, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(color: Colors.grey[300]))),
        const SizedBox(height: 4),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
        Text("$count mục", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
