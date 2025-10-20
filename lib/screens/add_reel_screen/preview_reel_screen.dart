import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/screens/main_screen/main_screen.dart';
import 'package:social_media_app/utils/overlay.dart';
import 'package:social_media_app/utils/save_uint8List_to_file.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';

import 'package:social_media_app/materials/app_colors.dart';

import '../../cubit/reel_bloc/reel_bloc.dart';
import '../../utils/dialogs.dart';

enum Audience { everyone, followers, onlyMe }

class ReelPreviewScreen extends StatefulWidget {
  static const String route = 'ReelPreviewScreen';

  const ReelPreviewScreen({super.key});

  @override
  State<ReelPreviewScreen> createState() => _ReelPreviewScreenState();
}

class _ReelPreviewScreenState extends State<ReelPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  bool _isGenerating = false;

  List<Uint8List> _thumbCandidates = [];
  Uint8List? _selectedThumbnail;
  static const int _thumbCount = 10;

  Size? _videoSize;
  int? _videoDurationMs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadVideoSize();
      await _generateSingleThumbnail(0);
      _generateThumbnails();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  String? get _videoPath {
    final state = context.read<ReelBloc>().state as dynamic;
    return state.reelMedia?.path ?? state.mediaFile?.path;
  }

  Future<void> _generateSingleThumbnail(int timeMs) async {
    final path = _videoPath;
    if (path == null) return;
    final bytes = await VideoThumbnail.thumbnailData(video: path, imageFormat: ImageFormat.JPEG, maxWidth: 256, quality: 50, timeMs: timeMs);
    if (bytes != null) {
      setState(() => _selectedThumbnail = bytes);
    }
  }

  Future<void> _generateThumbnails() async {
    final path = _videoPath;
    if (path == null) return;

    setState(() {
      _isGenerating = true;
      _thumbCandidates = [];
    });

    if (_videoDurationMs == null) {
      await _loadVideoSize();
    }

    try {
      final int count = _thumbCount;
      List<int> times = [];
      if (_videoDurationMs != null && _videoDurationMs! > 0) {
        final int dur = _videoDurationMs!;
        for (int i = 0; i < count; i++) {
          final int t = ((i + 1) * dur / (count + 1)).round();
          times.add(t);
        }
      } else {
        for (int i = 0; i < count; i++) {
          times.add(i * 1000);
        }
      }

      final batchSize = 3;
      for (int i = 0; i < times.length; i += batchSize) {
        final batch = times.skip(i).take(batchSize);
        final results = await Future.wait(
          batch.map((t) async {
            try {
              return await VideoThumbnail.thumbnailData(video: path, imageFormat: ImageFormat.JPEG, maxWidth: 256, quality: 50, timeMs: t);
            } catch (_) {
              return null;
            }
          }),
        );
        _thumbCandidates.addAll(results.whereType<Uint8List>());
        if (_thumbCandidates.length >= count) break;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Thumbnail generation failed overall: $e');
    }

    if (_thumbCandidates.isEmpty) {
      try {
        final fallback = await VideoThumbnail.thumbnailData(video: path, imageFormat: ImageFormat.JPEG, maxWidth: 512, quality: 70);
        if (fallback != null) _thumbCandidates.add(fallback);
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
        if (_thumbCandidates.isNotEmpty && _selectedThumbnail == null) _selectedThumbnail = _thumbCandidates.first;
      });
    }
  }

  Future<void> _loadVideoSize() async {
    final path = _videoPath;
    if (path == null) return;
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      final size = controller.value.size;
      final dur = controller.value.duration;
      if (mounted) {
        if (size.width > 0 && size.height > 0) _videoSize = size;
        if (dur.inMilliseconds > 0) _videoDurationMs = dur.inMilliseconds;
        setState(() {});
      }
    } catch (e) {
      debugPrint('Failed to load video size/duration: $e');
    } finally {
      try {
        await controller?.dispose();
      } catch (_) {}
    }
  }

  Future<void> _onShare(BuildContext context) async {
    final caption = _captionController.text.trim();
    final thumbImage = await saveUint8ListToFile(_selectedThumbnail!);
    if (context.mounted) {
      context.read<ReelBloc>().add(CreateReelEvent(file: context.read<ReelBloc>().state.reelMedia!, content: caption, thumbImage: thumbImage));
    }
  }

  Future<void> _openThumbnailPickerModal() async {
    if (_isGenerating) {
      showModalBottomSheet(
        context: context,
        builder:
            (_) => SizedBox(
              height: 200,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), SizedBox(height: 12), Text('Đang tạo ảnh bìa...')]),
              ),
            ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        // DraggableScrollableSheet trả về một ScrollController cho nội dung
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          // mặc định chiếm nửa màn hình
          minChildSize: 0.25,
          // khi thu nhỏ còn 1/4
          maxChildSize: 0.95,
          // có thể kéo gần full screen
          expand: false,
          builder: (context, scrollController) {
            // NotificationListener để phát hiện hành vi kéo xuống ở đỉnh
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // handle
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 12),
                  const Align(alignment: Alignment.centerLeft, child: Text('Chọn ảnh bìa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  const SizedBox(height: 12),

                  // Flexible chứa GridView dùng chung scrollController
                  Flexible(
                    child:
                        _thumbCandidates.isEmpty
                            ? SizedBox(height: 200, child: Center(child: Text('Không có thumbnail', style: Theme.of(context).textTheme.bodyMedium)))
                            : NotificationListener<ScrollNotification>(
                              onNotification: (notif) {
                                // Nếu đang ở đỉnh (pixels <= 0) và user kéo xuống nhanh (ScrollUpdateNotification với delta < -threshold)
                                // thì đóng modal. Giá trị threshold có thể tinh chỉnh (ở đây dùng -20).
                                if (notif is ScrollUpdateNotification) {
                                  final metrics = notif.metrics;
                                  final double pixels = metrics.pixels;
                                  final double? delta = notif.scrollDelta;
                                  // đảm bảo có delta (trong 1 vài trường hợp null)
                                  if (delta != null) {
                                    // khi ở đỉnh và kéo xuống (delta < 0) vượt ngưỡng -> đóng
                                    if (pixels <= 0 && delta < -20) {
                                      Navigator.of(ctx).pop();
                                      return true;
                                    }
                                  }
                                }

                                // Ngoài ra xử lý Overscroll (người dùng kéo vượt ra ngoài)
                                if (notif is OverscrollNotification) {
                                  // overscroll < 0 khi kéo xuống ở đỉnh (tuỳ platform): nếu vượt ngưỡng -> đóng
                                  if (notif.overscroll < -20 && notif.metrics.pixels <= 0) {
                                    Navigator.of(ctx).pop();
                                    return true;
                                  }
                                }
                                return false;
                              },
                              child: GridView.builder(
                                controller: scrollController,
                                // <<--- dùng chung controller
                                shrinkWrap: true,
                                itemCount: _thumbCandidates.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 9 / 16,
                                ),
                                itemBuilder: (ctx2, idx) {
                                  final bytes = _thumbCandidates[idx];
                                  final isSelected = _selectedThumbnail == bytes;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedThumbnail = bytes;
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(bytes, fit: BoxFit.cover)),
                                        if (isSelected)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                              child: const Icon(Icons.check, size: 18),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _actionRow({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        height: 56,
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReelBloc, ReelState>(
      listener: (context, state) async {
        if (state.loadReelStatus == LoadStatus.loading) {
          LoadingOverlay.show(context);
        } else {
          LoadingOverlay.hide();
        }
        if (state.loadReelStatus == LoadStatus.done) {
          final result = await showNotificationDialog(context, message: 'Create Reel successfully!');
          if (result == true && context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.route, (route) => false);
          }
        }
      },
      builder: (context, state) {
        return BlocBuilder<ReelBloc, ReelState>(
          builder: (context, state) {
            final screen = MediaQuery.of(context).size;
            final screenWidth = screen.width * 2 / 3;

            double displayHeight = screenWidth;
            double displayWidth = screenWidth;

            if (_videoSize != null && _videoSize!.height > 0 && _videoSize!.width > 0) {
              displayWidth = displayHeight * (_videoSize!.width / _videoSize!.height);

              if (displayWidth > screenWidth) {
                displayWidth = screenWidth;
                displayHeight = displayWidth * (_videoSize!.height / _videoSize!.width);
              }
            }

            return Theme(
              data: ThemeData.dark(),
              child: Scaffold(
                appBar: AppBar(title: const Text('Xem trước Reel')),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: displayWidth,
                            height: displayHeight,
                            child: Container(
                              color: Colors.black,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_selectedThumbnail != null)
                                    ClipRRect(borderRadius: BorderRadius.zero, child: Image.memory(_selectedThumbnail!, fit: BoxFit.cover))
                                  else if (_thumbCandidates.isNotEmpty)
                                    ClipRRect(borderRadius: BorderRadius.zero, child: Image.memory(_thumbCandidates.first, fit: BoxFit.cover))
                                  else
                                    const Center(child: Text('Không có thumbnail', style: TextStyle(color: Colors.white))),

                                  Positioned(
                                    left: 12,
                                    bottom: 12,
                                    child: GestureDetector(
                                      onTap: _openThumbnailPickerModal,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [Icon(Icons.image, size: 16), SizedBox(width: 8), Text('Chọn ảnh bìa')],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // body
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                              child: TextField(
                                controller: _captionController,
                                maxLines: null,
                                decoration: const InputDecoration(hintText: 'Viết chú thích...', border: InputBorder.none),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                children: [
                                  _actionRow(icon: Icons.person_add, label: 'Gắn thẻ người', onTap: () {}),
                                  _actionRow(icon: Icons.remove_red_eye, label: 'Ai có thể xem', onTap: () {}),
                                  _actionRow(icon: Icons.location_on_outlined, label: 'Thêm địa điểm', onTap: () {}),
                                  _actionRow(icon: Icons.more_horiz, label: 'Tùy chọn khác', onTap: () {}),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  minimum: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onShare(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Chia sẻ', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
