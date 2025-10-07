import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/screens/add_post_screen/edit_media_screen.dart';
import 'package:social_media_app/services/repositories/api/api.dart';

import '../../commons/widgets/display_video.dart';
import '../../commons/widgets/camera_screen.dart';

class AddPostScreen extends StatelessWidget {
  static const String route = 'AddPostScreen';

  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostCubit(context.read<Api>()),
      child: Theme(
        data: ThemeData.dark(),
        child: const Page(),
      ),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  final List<AssetEntity> _mediaList = [];
  List<Map<AssetPathEntity, int>> _albums = [];
  AssetEntity? currentAsset;
  AssetPathEntity? _currentAlbum;
  String _albumName = "Mới đây";
  bool isMultiplyChoice = false;
  bool _pausePreview = false;

  bool _loading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  final int _pageSize = 40;
  final ScrollController _scrollController = ScrollController();

  final Map<String, Uint8List> _thumbCache = {};
  final List<String> _thumbCacheKeys = [];
  final int _thumbCacheMaxEntries = 150;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPermission();
    });
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initPermission() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      PhotoManager.openSetting();
      if (mounted) setState(() => _loading = false);
      return;
    }

    await _loadAlbums();
    await _loadInitialMedia();

    if (mounted) {
      setState(() {
        _loading = false;
        if (_mediaList.isNotEmpty) {
          currentAsset = _mediaList.first;
          context.read<PostCubit>().addToSelectedAssets(currentAsset!);
        }
      });
    }
  }

  Future<void> _loadAlbums() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: false,
    );
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
    _clearThumbCache();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentAlbum == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final newMedia = await _currentAlbum!.getAssetListPaged(page: _page, size: _pageSize);
      if (mounted) {
        setState(() {
          _mediaList.addAll(newMedia);
          _page++;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<Uint8List?> _getThumb(AssetEntity asset, {int width = 200, int height = 200}) async {
    final id = asset.id;
    if (_thumbCache.containsKey(id)) {
      _thumbCacheKeys.remove(id);
      _thumbCacheKeys.add(id);
      return _thumbCache[id];
    }
    final data = await asset.thumbnailDataWithSize(ThumbnailSize(width, height));
    if (data != null) {
      _thumbCache[id] = data;
      _thumbCacheKeys.add(id);
      if (_thumbCacheKeys.length > _thumbCacheMaxEntries) {
        final oldest = _thumbCacheKeys.removeAt(0);
        _thumbCache.remove(oldest);
      }
    }
    return data;
  }

  void _clearThumbCache() {
    _thumbCache.clear();
    _thumbCacheKeys.clear();
  }

  void _toggleSelect(AssetEntity asset) {
    final cubit = context.read<PostCubit>();
    if (isMultiplyChoice) {
      cubit.toggleMultiSelect(asset);
    } else {
      cubit.selectSingle(asset);
    }
    setState(() {
      currentAsset = asset;
    });
  }

  int _selectedIndex(int index) => index == -1 ? 0 : index + 1;

  void _chooseAlbum(AssetPathEntity album) async {
    _currentAlbum = album;
    _albumName = album.name.isNotEmpty ? album.name : "Không tên";
    _clearThumbCache();
    await _loadInitialMedia();

    if (mounted) {
      setState(() {
        if (_mediaList.isNotEmpty) {
          currentAsset = _mediaList.first;
        } else {
          currentAsset = null;
        }
      });
      Navigator.pop(context);
    }
  }

  Future<File?> getFile() async {
    if (currentAsset == null) return null;
    return await currentAsset!.file;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        final totalItemCount = 1 + _mediaList.length + (_isLoadingMore ? 1 : 0);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Chọn ảnh/video"),
            actions: [
              TextButton(
                onPressed: () async {
                  if (cubit.state.selectedAssets.isNotEmpty) {
                    await cubit.loadData();
                    if (context.mounted) {
                      cubit.setIndex(0);
                      setState(() => _pausePreview = true);
                      Navigator.of(context)
                          .pushNamed(EditMediaScreen.route, arguments: {'cubit': cubit})
                          .then((_) {
                        if (!mounted) return;
                        setState(() => _pausePreview = false);
                      });
                    }
                  }
                },
                child: Text(
                  "Xong (${cubit.state.selectedAssets.length})",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Preview
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: currentAsset == null
                    ? const Center(child: Icon(Icons.image_outlined, size: 80))
                    : currentAsset!.type == AssetType.image
                    ? FutureBuilder<Uint8List?>(
                  future: _getThumb(currentAsset!, width: 1000, height: 1000),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(color: Colors.black12);
                    }
                    return Image.memory(snapshot.data!, fit: BoxFit.contain);
                  },
                )
                    : FutureBuilder<File?>(
                  future: getFile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Icon(Icons.broken_image));
                    }
                    final videoFile = snapshot.data!;
                    return Video(
                      key: ValueKey(currentAsset!.id),
                      video: videoFile,
                      shouldPlay: currentAsset!.type == AssetType.video && !_pausePreview,
                    );
                  },
                ),
              ),

              // Gallery
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _showAlbumPicker,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          label: Text(_albumName),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isMultiplyChoice = !isMultiplyChoice;
                              if (cubit.state.selectedAssets.isNotEmpty) {
                                cubit.clearSelected();
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isMultiplyChoice
                                  ? Theme.of(context).colorScheme.primary.withAlpha(224)
                                  : Theme.of(context).colorScheme.onSurface.withAlpha(32),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.filter_none,
                              size: 16,
                              color: isMultiplyChoice
                                  ? AppColors.textLight
                                  : Theme.of(context).colorScheme.onSurface.withAlpha(224),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: totalItemCount,
                        itemBuilder: (_, index) {
                          final loaderIndex = 1 + _mediaList.length;
                          if (_isLoadingMore && index == loaderIndex) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (index == 0) {
                            // Camera tile
                            return GestureDetector(
                              onTap: () async {
                                if (!isMultiplyChoice) {
                                  final result = await Navigator.of(context)
                                      .pushNamed(CameraScreen.route) as Map<String, dynamic>?;
                                  if (!mounted) return;
                                  if (result != null && result.containsKey('file')) {
                                    final file = result['file'] as File?;
                                    final mediaType = result['mediaType'] as String?;
                                    if (file != null && mediaType != null) {
                                      if (!context.mounted) return;
                                      context.read<PostCubit>().addToAsset({'file': file, 'type': mediaType});
                                      if (!context.mounted) return;
                                      setState(() => _pausePreview = true);
                                      Navigator.of(context)
                                          .pushNamed(EditMediaScreen.route, arguments: {'cubit': cubit})
                                          .then((_) {
                                        if (!mounted) return;
                                        setState(() => _pausePreview = false);
                                      });
                                    }
                                  }
                                }
                              },
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      color: Theme.of(context).colorScheme.surface.withAlpha(224),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 56,
                                        color: Theme.of(context).colorScheme.onSurface.withAlpha(224),
                                      ),
                                    ),
                                  ),
                                  if (isMultiplyChoice) Container(color: Colors.black.withAlpha(70)),
                                ],
                              ),
                            );
                          }

                          final assetIndex = index - 1;
                          if (assetIndex < 0 || assetIndex >= _mediaList.length) {
                            return const SizedBox.shrink();
                          }
                          final asset = _mediaList[assetIndex];

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              GestureDetector(
                                onTap: () => _toggleSelect(asset),
                                child: FutureBuilder<Uint8List?>(
                                  future: _getThumb(asset),
                                  builder: (_, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(color: Colors.grey[300]);
                                    }
                                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                  },
                                ),
                              ),
                              if (asset.type == AssetType.video)
                                Positioned(
                                  bottom: 2,
                                  right: 4,
                                  child: Text(
                                    "${(asset.duration ~/ 60).toString().padLeft(2, '0')}:${(asset.duration % 60).toString().padLeft(2, '0')}",
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              if (isMultiplyChoice)
                                _buildMultiSelectOverlay(cubit, asset)
                              else if (_selectedIndex(cubit.state.selectedAssets.indexOf(asset)) > 0)
                                GestureDetector(
                                  onTap: () {
                                    _toggleSelect(asset);
                                  },
                                  child: Container(color: AppColors.textMutedDark.withAlpha(92)),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultiSelectOverlay(PostCubit cubit, AssetEntity asset) {
    final selectedIndex = _selectedIndex(cubit.state.selectedAssets.indexOf(asset));
    return Stack(
      children: [
        if (selectedIndex > 0)
          GestureDetector(
            onTap: () => _toggleSelect(asset),
            child: Container(color: AppColors.textMutedDark.withAlpha(92)),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              cubit.toggleMultiSelect(asset);
              setState(() {
                currentAsset = asset;
              });
            },
            child: selectedIndex > 0
                ? Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "$selectedIndex",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            )
                : Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(64),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textLight, width: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAlbumPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Theme(
              data: ThemeData.dark(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(icon: Icons.collections, label: "Gần đây", onTap: () async {
                        _albumName = "Gần đây";
                        final list = await PhotoManager.getAssetPathList(type: RequestType.common, onlyAll: true);
                        if (list.isNotEmpty) {
                          _chooseAlbum(list.first);
                        }
                      }),
                      _buildFilterButton(icon: Icons.image, label: "Ảnh", onTap: () async {
                        _albumName = "Ảnh";
                        final list = await PhotoManager.getAssetPathList(type: RequestType.image, onlyAll: true);
                        if (list.isNotEmpty) {
                          _chooseAlbum(list.first);
                        }
                      }),
                      _buildFilterButton(icon: Icons.video_collection, label: "Video", onTap: () async {
                        _albumName = "Video";
                        final list = await PhotoManager.getAssetPathList(type: RequestType.video, onlyAll: true);
                        if (list.isNotEmpty) {
                          _chooseAlbum(list.first);
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _albums.length,
                      itemBuilder: (context, index) {
                        final album = _albums[index];
                        final albumEntity = album.keys.first;
                        final count = album.values.first;
                        final name = albumEntity.name.isNotEmpty ? albumEntity.name : "Không tên";

                        return FutureBuilder<List<AssetEntity>>(
                          future: albumEntity.getAssetListRange(start: 0, end: 1),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return _buildAlbumPlaceholder(name, count);
                            }
                            final firstAsset = snapshot.data!.first;
                            return FutureBuilder<Uint8List?>(
                              future: firstAsset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                              builder: (context, thumbSnap) {
                                if (!thumbSnap.hasData) {
                                  return _buildAlbumPlaceholder(name, count);
                                }
                                return GestureDetector(
                                  onTap: () => _chooseAlbum(albumEntity),
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
                                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
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
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text("$count mục", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
