import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/materials/app_text_styles.dart';
import 'package:social_media_app/screens/add_post_screen/edit_media_screen.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends StatefulWidget {
  static const String route = 'AddPostScreen';

  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
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
  final List<AssetEntity> _mediaList = [];
  final List<AssetEntity> _selectedList = [];
  List<Map<AssetPathEntity, int>> _albums = [];
  AssetPathEntity? _currentAlbum;
  String _albumName = "Mới đây";
  bool isMultiplyChoice = false;

  bool _loading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  final int _pageSize = 40;
  final ScrollController _scrollController = ScrollController();
  final Map<String, Uint8List> _thumbCache = {};

  int _selectedCarouselIndex = 0;
  int _selectedMediaIndex = 0;

  final ImagePicker _picker = ImagePicker();

  Future<void> _captureAndGetAsset() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    final AssetEntity asset = await PhotoManager.editor.saveImageWithPath(
      file.path,
    );

    setState(() {
      _selectedList.clear();
      _selectedList.add(asset);
    });
  }

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
      return;
    }
    await _loadAlbums();
    await _loadInitialMedia();
    setState(() => _loading = false);
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
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentAlbum == null) return;
    setState(() => _isLoadingMore = true);

    final newMedia = await _currentAlbum!.getAssetListPaged(
      page: _page,
      size: _pageSize,
    );

    setState(() {
      _mediaList.addAll(newMedia);
      _page++;
      _isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<Uint8List?> _getThumb(
    AssetEntity asset, {
    int width = 200,
    int height = 200,
  }) async {
    if (_thumbCache.containsKey(asset.id)) {
      return _thumbCache[asset.id];
    }
    final data = await asset.thumbnailDataWithSize(
      ThumbnailSize(width, height),
    );
    if (data != null) _thumbCache[asset.id] = data;
    return data;
  }

  void _toggleSelect(AssetEntity asset) {
    setState(() {
      if (isMultiplyChoice) {
        if (_selectedList.contains(asset)) {
          if (_selectedList.indexOf(asset) == _selectedMediaIndex) {
            _selectedList.remove(asset);
            if (_selectedList.isNotEmpty) {
              _selectedMediaIndex -=
                  _selectedMediaIndex == _selectedList.length ? 1 : 0;
            } else {
              _selectedMediaIndex = 0;
            }
          } else {
            _selectedMediaIndex = _selectedList.indexOf(asset);
          }
        } else {
          _selectedList.add(asset);
        }
      } else {
        if (_selectedList.isEmpty) {
          _selectedList.add(asset);
        } else {
          _selectedList[0] = asset;
        }
      }
    });
  }

  int _selectedIndex(AssetEntity asset) {
    final index = _selectedList.indexOf(asset);
    return index == -1 ? 0 : index + 1;
  }

  void _chooseAlbum(AssetPathEntity album) async {
    _currentAlbum = album;
    _albumName = album.name.isNotEmpty ? album.name : "Không tên";
    await _loadInitialMedia();
    if (mounted) Navigator.pop(context);
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

    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn ảnh/video"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditMediaScreen.route,
                arguments: {'assets': _selectedList},
              );
            },
            child: Text(
              "Xong (${_selectedList.length})",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(children: [_buildPostScreen(), _buildSelectionTabs()]),
    );
  }

  Widget _buildPostScreen() {
    return Column(
      children: [
        // Preview trên
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child:
              _selectedList.isEmpty
                  ? const Center(child: Icon(Icons.image_outlined, size: 80))
                  : _selectedList[_selectedMediaIndex].type == AssetType.image
                  ? FutureBuilder<Uint8List?>(
                    future: _getThumb(
                      _selectedList[_selectedMediaIndex],
                      width: 1000,
                      height: 1000,
                    ),
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(color: Colors.black12);
                      }
                      return Image.memory(snapshot.data!, fit: BoxFit.contain);
                    },
                  )
                  : Video(
                    key: ValueKey(_selectedList[_selectedMediaIndex].id),
                    video: _selectedList[_selectedMediaIndex],
                  ),
        ),

        // Gallery dưới
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
                        _selectedList.clear();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color:
                            isMultiplyChoice
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(224)
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(32),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.filter_none,
                        size: 16,
                        color:
                            isMultiplyChoice
                                ? AppColors.textLight
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(224),
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
                  itemCount: _mediaList.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index >= _mediaList.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () async {
                          await _captureAndGetAsset();
                        },
                        child: Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withAlpha(224),
                          child: Icon(
                            Icons.camera_alt,
                            size: 56,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(224),
                          ),
                        ),
                      );
                    }
                    final asset = _mediaList[index];
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
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        if (asset.type == AssetType.video)
                          Positioned(
                            bottom: 2,
                            right: 4,
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                Text(
                                  "${(asset.duration ~/ 60).toString().padLeft(2, '0')}:${(asset.duration % 60).toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isMultiplyChoice)
                          Stack(
                            children: [
                              if (_selectedIndex(asset) > 0)
                                GestureDetector(
                                  onTap: () => _toggleSelect(asset),
                                  child: Container(
                                    color: AppColors.textMutedDark.withAlpha(
                                      92,
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child:
                                    _selectedIndex(asset) > 0
                                        ? Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${_selectedIndex(asset)}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        )
                                        : Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withAlpha(64),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.textLight,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () => _toggleSelect(asset),
                            child:
                                _selectedIndex(asset) > 0
                                    ? Container(
                                      color: AppColors.textMutedDark.withAlpha(
                                        92,
                                      ),
                                    )
                                    : null,
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
    );
  }

  Widget _buildSelectionTabs() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Theme.of(context).colorScheme.surface.withAlpha(240),
          ),
          child: CarouselSlider(
            items: [
              Center(
                child: Text(
                  'Bài đăng',
                  style: AppTextStyles.subHeadline(context),
                ),
              ),
              Center(
                child: Text('Reels', style: AppTextStyles.subHeadline(context)),
              ),
              Center(
                child: Text('Tin', style: AppTextStyles.subHeadline(context)),
              ),
            ],
            options: CarouselOptions(
              height: 50,
              viewportFraction: 0.4,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() => _selectedCarouselIndex = index);
                // TODO: Lọc gallery ở dưới theo tab
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAlbumPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // 3 nút chọn chế độ lọc
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterButton(
                      icon: Icons.collections,
                      label: "Gần đây",
                      onTap: () async {
                        _albumName = "Gần đây";
                        _currentAlbum =
                            (await PhotoManager.getAssetPathList(
                              type: RequestType.common,
                              onlyAll: true,
                            )).first;
                        await _loadInitialMedia();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                    _buildFilterButton(
                      icon: Icons.image,
                      label: "Ảnh",
                      onTap: () async {
                        _albumName = "Ảnh";
                        _currentAlbum =
                            (await PhotoManager.getAssetPathList(
                              type: RequestType.image,
                              onlyAll: true,
                            )).first;
                        await _loadInitialMedia();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                    _buildFilterButton(
                      icon: Icons.video_collection,
                      label: "Video",
                      onTap: () async {
                        _albumName = "Video";
                        _currentAlbum =
                            (await PhotoManager.getAssetPathList(
                              type: RequestType.video,
                              onlyAll: true,
                            )).first;
                        await _loadInitialMedia();
                        if (mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // GridView danh sách album
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                      final albumNameSafe =
                          albumEntity.name.isNotEmpty
                              ? albumEntity.name
                              : "Không tên";

                      return FutureBuilder<List<AssetEntity>>(
                        future: albumEntity.getAssetListRange(start: 0, end: 1),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildAlbumPlaceholder(albumNameSafe, count);
                          }
                          final firstAsset = snapshot.data!.first;
                          return FutureBuilder<Uint8List?>(
                            future: firstAsset.thumbnailDataWithSize(
                              const ThumbnailSize(300, 300),
                            ),
                            builder: (context, thumbSnap) {
                              if (!thumbSnap.hasData) {
                                return _buildAlbumPlaceholder(
                                  albumNameSafe,
                                  count,
                                );
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
                                        child: Image.memory(
                                          thumbSnap.data!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      albumNameSafe,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "$count mục",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
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
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.black87),
          ),
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
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(color: Colors.grey[300]),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          "$count mục",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class Video extends StatefulWidget {
  final AssetEntity video;

  const Video({super.key, required this.video});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final file = await widget.video.file;
    if (file != null) {
      _controller =
          VideoPlayerController.file(file)
            ..setLooping(true) // lặp lại video
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
                _controller!.play();
              }
            });
    }
  }

  @override
  void didUpdateWidget(covariant Video oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu video mới khác video cũ thì reset controller
    if (oldWidget.video.id != widget.video.id) {
      _controller?.dispose();
      _controller = null;
      _initVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
