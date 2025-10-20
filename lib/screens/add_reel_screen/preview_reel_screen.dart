import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../commons/widgets/display_video.dart';
import '../../cubit/reel_bloc/reel_bloc.dart';

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
  final List<String> _tags = [];
  Audience _audience = Audience.everyone;

  bool _isSharing = false;
  bool _isGenerating = false;

  List<Uint8List> _thumbCandidates = [];
  Uint8List? _selectedThumbnail;
  static const int _thumbCount = 6;

  @override
  void initState() {
    super.initState();
    // generate thumbnails after first frame so that ReelBloc state is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateThumbnails());
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  String? get _videoPath {
    final state = context.read<ReelBloc>().state as dynamic;
    // try common property names; adapt if yours khác
    return state.reelMedia?.path ?? state.mediaFile?.path;
  }

  Future<void> _generateThumbnails() async {
    final path = _videoPath;
    if (path == null) return;

    setState(() {
      _isGenerating = true;
      _thumbCandidates = [];
    });

    try {
      for (int i = 0; i < _thumbCount; i++) {
        // heuristic: request thumbnails (video_thumbnail chooses a frame)
        final bytes = await VideoThumbnail.thumbnailData(video: path, imageFormat: ImageFormat.PNG, maxWidth: 512, quality: 75);
        if (bytes != null) _thumbCandidates.add(bytes);
        if (_thumbCandidates.length >= _thumbCount) break;
      }
    } catch (e) {
      debugPrint('Thumbnail generation failed: $e');
    }

    if (_thumbCandidates.isEmpty) {
      try {
        final fallback = await VideoThumbnail.thumbnailData(video: path, imageFormat: ImageFormat.JPEG, maxWidth: 512, quality: 70);
        if (fallback != null) _thumbCandidates.add(fallback);
      } catch (_) {}
    }

    setState(() {
      _isGenerating = false;
      if (_thumbCandidates.isNotEmpty && _selectedThumbnail == null) _selectedThumbnail = _thumbCandidates.first;
    });
  }

  void _addTagFromInput() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) return;
    setState(() {
      if (!_tags.contains(tag)) _tags.add(tag);
      _tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _onShare() async {
    setState(() => _isSharing = true);

    final payload = {'caption': _captionController.text.trim(), 'thumbnail': _selectedThumbnail, 'tags': _tags, 'audience': _audience};

    // Try to call a convenience upload function on ReelBloc if it exists:
    // - If your ReelBloc exposes a method like `uploadReel(Map)` or `createReel(...)`,
    //   this dynamic call will invoke it.
    // - If not, fallback to popping the payload so caller can handle upload.
    try {
      final bloc = context.read<ReelBloc>() as dynamic;
      // Attempt to call common method names, wrapped in try/catch.
      // Replace or extend names according to your ReelBloc implementation.
      if (bloc.uploadReel != null) {
        final res = bloc.uploadReel(payload);
        if (res is Future) await res;
        // optionally you can listen to bloc state changes instead of immediate pop
        if (mounted) Navigator.of(context).pop(true); // success - close or adjust as needed
      } else if (bloc.createReel != null) {
        final res = bloc.createReel(payload);
        if (res is Future) await res;
        if (mounted) Navigator.of(context).pop(true);
      } else {
        // no helper method found: return payload to caller
        if (mounted) Navigator.of(context).pop(payload);
      }
    } catch (e) {
      // if dynamic call failed (method not found) -> fallback pop payload
      if (mounted) Navigator.of(context).pop(payload);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Widget _buildAudienceSelector() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: const Text('Mọi người'),
            selected: _audience == Audience.everyone,
            onSelected: (_) => setState(() => _audience = Audience.everyone),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Follower'),
            selected: _audience == Audience.followers,
            onSelected: (_) => setState(() => _audience = Audience.followers),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            label: const Text('Riêng tư'),
            selected: _audience == Audience.onlyMe,
            onSelected: (_) => setState(() => _audience = Audience.onlyMe),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailPicker() {
    if (_isGenerating) {
      return SizedBox(
        height: 84,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Đang tạo thumbnail...'),
            ],
          ),
        ),
      );
    }

    if (_thumbCandidates.isEmpty) {
      return SizedBox(height: 84, child: Center(child: Text('Không có thumbnail khả dụng', style: Theme.of(context).textTheme.bodyMedium)));
    }

    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _thumbCandidates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final bytes = _thumbCandidates[index];
          final isSelected = _selectedThumbnail == bytes;
          return GestureDetector(
            onTap: () => setState(() => _selectedThumbnail = bytes),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: isSelected ? const EdgeInsets.all(4) : EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(bytes, width: 120, height: 72, fit: BoxFit.cover)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelBloc, ReelState>(
      builder: (context, state) {
        final file = state.reelMedia;
        final aspectRatio = 9 / 16;

        final screen = MediaQuery.of(context).size;
        final previewHeight = screen.width / aspectRatio / 2;

        return Theme(
          data: ThemeData.dark(),
          child: Scaffold(
            appBar: AppBar(title: const Text('Xem trước Reel')),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // TOP preview area
                    SizedBox(
                      height: previewHeight,
                      width: screen.width / 3,
                      child: Container(
                        color: Colors.black,
                        child:
                            file == null
                                ? const Center(child: Text('Không có video', style: TextStyle(color: Colors.white)))
                                : SmartVideo(file: file, shouldPlay: false),
                      ),
                    ),

                    // body
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // caption
                        TextField(
                          controller: _captionController,
                          maxLines: 4,
                          maxLength: 2200,
                          decoration: const InputDecoration(hintText: 'Viết chú thích...', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),

                        // thumbnail picker
                        const Text('Chọn thumbnail', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildThumbnailPicker(),
                        const SizedBox(height: 12),

                        // tags
                        const Text('Gắn thẻ', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _tagController,
                                onSubmitted: (_) => _addTagFromInput(),
                                decoration: const InputDecoration(hintText: 'Nhập tên người / hashtag và Enter', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(onPressed: _addTagFromInput, child: const Text('Thêm')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) => Chip(label: Text(t), onDeleted: () => _removeTag(t))).toList()),

                        const SizedBox(height: 12),

                        // audience
                        const Text('Ai có thể xem', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildAudienceSelector(),

                        const SizedBox(height: 24),

                        // extra actions
                        Row(
                          children: [
                            IconButton(onPressed: () {}, icon: const Icon(Icons.person_add)),
                            const SizedBox(width: 8),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.location_on)),
                            const SizedBox(width: 8),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.music_note)),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),

                    // bottom share button
                    Theme(
                      data: ThemeData.dark(),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSharing ? null : _onShare,
                                child:
                                    _isSharing
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Text('Chia sẻ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
