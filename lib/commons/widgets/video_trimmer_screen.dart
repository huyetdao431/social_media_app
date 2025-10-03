// video_trim_screen_ffmpeg.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

/// Màn hình trim video dùng VideoPlayer + FFmpeg
class VideoTrimScreen extends StatelessWidget {
  static const String route = 'VideoTrimScreen';
  final File file;

  const VideoTrimScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Theme(data: ThemeData.dark(), child: Page(file: file));
  }
}

class Page extends StatefulWidget {
  final File file;

  const Page({super.key, required this.file});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  // Config
  static const double minTrimSec = 10.0;
  static const double maxTrimSec = 60.0;
  static const double _endEpsilon = 0.05;

  // Video player
  VideoPlayerController? _controller;
  VoidCallback? _positionListener;

  // State
  Duration? _videoDuration;
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _removePositionListener();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.file(widget.file);
    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Video initialize error: $e');
    }

    _videoDuration = _controller?.value.duration;
    _startValue = 0.0;
    _endValue = (_videoDuration?.inMilliseconds ?? 0) / 1000.0;
    _ensureBounds();

    // add listener to update UI and to stop at end
    _addPositionListener();
    setState(() {});
  }

  void _ensureBounds() {
    final total = (_videoDuration?.inMilliseconds ?? 0) / 1000.0;
    if (total <= 0) return;

    _startValue = _startValue.clamp(0.0, total);
    _endValue = _endValue.clamp(0.0, total);

    double length = _endValue - _startValue;

    if (length < minTrimSec) {
      if (_startValue + minTrimSec <= total) {
        _endValue = _startValue + minTrimSec;
      } else {
        _startValue = (_endValue - minTrimSec).clamp(0.0, total);
        _endValue = (_startValue + minTrimSec).clamp(0.0, total);
      }
    }

    length = _endValue - _startValue;
    if (length > maxTrimSec) {
      _endValue = _startValue + maxTrimSec;
    }
  }

  String _formatSeconds(double s) {
    final total = Duration(milliseconds: (s * 1000).round());
    String two(int v) => v.toString().padLeft(2, '0');
    final hh = two(total.inHours);
    final mm = two(total.inMinutes.remainder(60));
    final ss = two(total.inSeconds.remainder(60));
    return hh == '00' ? '$mm:$ss' : '$hh:$mm:$ss';
  }

  bool get _isSelectionValid {
    final len = _endValue - _startValue;
    return len >= minTrimSec && len <= maxTrimSec;
  }

  // --- Player listener management ---
  void _removePositionListener() {
    if (_controller != null && _positionListener != null) {
      try {
        _controller!.removeListener(_positionListener!);
      } catch (_) {}
      _positionListener = null;
    }
  }

  void _addPositionListener() {
    final ctrl = _controller;
    if (ctrl == null) return;

    _removePositionListener();

    _positionListener = () {
      // update isPlaying flag for overlay
      final playing = ctrl.value.isPlaying;
      if (mounted && playing != _isPlaying) {
        setState(() => _isPlaying = playing);
      }

      // stop at end of trim
      final posSec = ctrl.value.position.inMilliseconds / 1000.0;
      if (ctrl.value.isInitialized && ctrl.value.isPlaying && posSec >= _endValue - _endEpsilon) {
        try {
          ctrl.pause();
        } catch (_) {}
        // optionally seek to end or keep at end
        _removePositionListener(); // will be re-added on play
        if (mounted) setState(() => _isPlaying = false);
      }
    };

    ctrl.addListener(_positionListener!);
  }

  // --- Playback control ---
  Future<void> _togglePlayback() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    if (ctrl.value.isPlaying) {
      await ctrl.pause();
      _removePositionListener();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    // Seek to trim start then play
    await ctrl.seekTo(Duration(milliseconds: (_startValue * 1000).round()));
    _addPositionListener();
    await ctrl.play();
    if (mounted) setState(() => _isPlaying = true);
  }

  Future<void> _seekTo(double seconds, {bool onlyIfPlaying = false}) async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (onlyIfPlaying && !ctrl.value.isPlaying) return;
    await ctrl.seekTo(Duration(milliseconds: (seconds * 1000).round()));
  }

  void _moveSelectionBy(double deltaSeconds) {
    final total = (_videoDuration?.inMilliseconds ?? 0) / 1000.0;
    if (total <= 0) return;
    final selLen = _endValue - _startValue;
    double newStart = (_startValue + deltaSeconds).clamp(0.0, total);
    double newEnd = newStart + selLen;
    if (newEnd > total) {
      newEnd = total;
      newStart = (total - selLen).clamp(0.0, total);
    }
    setState(() {
      _startValue = newStart;
      _endValue = newEnd;
      _ensureBounds();
    });
    _seekTo(_startValue, onlyIfPlaying: true);
  }

  // --- Save via FFmpeg (try copy then fallback to re-encode) ---
  Future<void> _saveAndFinish() async {
    _ensureBounds();
    if (!_isSelectionValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selection phải từ ${minTrimSec.toInt()}s đến ${maxTrimSec.toInt()}s')),
      );
      return;
    }

    if (!widget.file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Input file không tồn tại')));
      return;
    }

    setState(() => _isSaving = true);

    // pause playback & remove listener
    try {
      if (_controller != null && _controller!.value.isPlaying) await _controller!.pause();
    } catch (_) {}
    _removePositionListener();

    final tmp = await getTemporaryDirectory();
    final outDir = Directory('${tmp.path}/trimmed_videos');
    if (!outDir.existsSync()) await outDir.create(recursive: true);
    final outPath = '${outDir.path}/trim_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final inputPath = widget.file.path;
    final start = _startValue;
    final duration = (_endValue - _startValue);

    // 1) try fast copy
    final cmdCopy = '-y -ss $start -i "$inputPath" -t $duration -c copy "$outPath"';
    debugPrint('FFmpeg copy cmd: $cmdCopy');

    try {
      final session = await FFmpegKit.execute(cmdCopy);
      final rc = await session.getReturnCode();
      if (ReturnCode.isSuccess(rc)) {
        // success
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trim thành công: $outPath')));
        Navigator.of(context).pop<File>(File(outPath));
        return;
      } else {
        debugPrint('FFmpeg copy failed rc=${rc?.getValue()} -> fallback to re-encode');
      }
    } catch (e, st) {
      debugPrint('FFmpeg copy exception: $e\n$st');
    }

    // 2) fallback: re-encode (safer)
    final outPathRe = '${outDir.path}/trim_recode_${DateTime.now().millisecondsSinceEpoch}.mp4';
    // safe re-encode command: libx264 + aac, preset veryfast
    final cmdRecode =
        '-y -ss $start -i "$inputPath" -t $duration -c:v libx264 -preset veryfast -crf 23 -c:a aac -b:a 128k "$outPathRe"';
    debugPrint('FFmpeg re-encode cmd: $cmdRecode');

    try {
      final session2 = await FFmpegKit.execute(cmdRecode);
      final rc2 = await session2.getReturnCode();
      if (ReturnCode.isSuccess(rc2)) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trim (re-encode) thành công: $outPathRe')));
        Navigator.of(context).pop<File>(File(outPathRe));
        return;
      } else {
        debugPrint('FFmpeg re-encode failed rc=${rc2?.getValue()}');
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trim thất bại (FFmpeg)')));
        }
      }
    } catch (e, st) {
      debugPrint('FFmpeg re-encode exception: $e\n$st');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trim thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- Build UI ---
  @override
  Widget build(BuildContext context) {
    final totalSec = (_videoDuration?.inMilliseconds ?? 0) / 1000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trim video'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: (_isSaving || !_isSelectionValid) ? null : _saveAndFinish,
              icon: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.navigate_next),
            ),
          ),
        ],
      ),
      body: _videoDuration == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Video preview
            Expanded(
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _togglePlayback,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      if (!_isPlaying)
                        const Icon(Icons.play_arrow, size: 64, color: Colors.white70)
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // time readout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_formatSeconds(_startValue)), Text(_formatSeconds(_endValue))],
            ),
            const SizedBox(height: 8),

            // TimelineTrimWidget (dùng background thay cho thumbnails)
            if (totalSec > 0)
              TimelineTrimWidget(
                total: totalSec,
                start: _startValue,
                end: _endValue,
                minSelection: minTrimSec,
                height: 64,
                onStartChanged: (v) {
                  setState(() {
                    _startValue = v;
                    _ensureBounds();
                  });
                  _seekTo(_startValue, onlyIfPlaying: true);
                },
                onEndChanged: (v) {
                  setState(() {
                    _endValue = v;
                    _ensureBounds();
                  });
                },
                onMoveBy: (d) => _moveSelectionBy(d),
              ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _TimelineTicksPainter extends CustomPainter {
  final double total;
  final double strokeWidth;
  final double majorTickHeight;
  final double minorTickHeight;
  final double extraMajorHeight;
  final Color color;

  _TimelineTicksPainter({
    required this.total,
    this.strokeWidth = 2.8,
    this.majorTickHeight = 18.0,
    this.minorTickHeight = 10.0,
    this.extraMajorHeight = 1.0,
    this.color = const Color(0xFF9E9E9E),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(220)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final int ticks = (total <= 0) ? 0 : (total <= 30 ? total.ceil().toInt() : 20);
    if (ticks <= 0) return;

    final centerY = size.height / 2;
    final double effectiveMajor = majorTickHeight + extraMajorHeight;

    for (int i = 0; i <= ticks; i++) {
      final dx = size.width * (i / ticks);
      final bool isMajor = (i % 5 == 0);
      final double tickH = isMajor ? effectiveMajor : minorTickHeight;

      final start = Offset(dx, centerY - tickH / 2);
      final end = Offset(dx, centerY + tickH / 2);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineTicksPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.majorTickHeight != majorTickHeight ||
        oldDelegate.minorTickHeight != minorTickHeight ||
        oldDelegate.extraMajorHeight != extraMajorHeight ||
        oldDelegate.color != color;
  }
}

class TimelineTrimWidget extends StatefulWidget {
  final double total; // seconds
  final double start; // seconds
  final double end; // seconds
  final double minSelection; // seconds
  final double height;
  final double handleHitWidth;
  final ValueChanged<double> onStartChanged;
  final ValueChanged<double> onEndChanged;
  final ValueChanged<double> onMoveBy;

  const TimelineTrimWidget({
    super.key,
    required this.total,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onMoveBy,
    this.minSelection = 1.0,
    this.height = 64.0,
    this.handleHitWidth = 22.0,
  });

  @override
  State<TimelineTrimWidget> createState() => _TimelineTrimWidgetState();
}

enum _HandleDragMode { none, left, right, move }

class _TimelineTrimWidgetState extends State<TimelineTrimWidget> {
  _HandleDragMode _mode = _HandleDragMode.none;
  static const Duration _animDur = Duration(milliseconds: 90);

  double _pxToSec(double dx, double width) {
    if (widget.total <= 0 || width <= 0) return 0.0;
    return (dx / width) * widget.total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primary = cs.primary;
    final onPrimary = cs.onPrimary;
    final dimColor = theme.brightness == Brightness.dark ? Colors.black.withAlpha(130) : Colors.white.withAlpha(156);

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final leftPx = widget.total <= 0 ? 0.0 : (widget.start / widget.total) * width;
            final selWidthPx = widget.total <= 0 ? 0.0 : ((widget.end - widget.start) / widget.total) * width;
            final handleHit = widget.handleHitWidth;

            return Stack(
              fit: StackFit.passthrough,
              children: [
                // Background (placeholder for thumbnails). Bạn có thể thay bằng thumbnails later.
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.black26, Colors.black54]),
                    ),
                  ),
                ),

                // left dim
                if (leftPx > 0) Positioned(left: 0, top: 0, bottom: 0, width: leftPx, child: Container(decoration: BoxDecoration(color: dimColor))),

                // right dim
                if (leftPx + selWidthPx < width)
                  Positioned(
                    left: leftPx + selWidthPx,
                    top: 0,
                    bottom: 0,
                    width: width - (leftPx + selWidthPx),
                    child: Container(decoration: BoxDecoration(color: dimColor)),
                  ),

                // ticks
                Positioned.fill(child: IgnorePointer(child: CustomPaint(size: Size(double.infinity, 36), painter: _TimelineTicksPainter(total: widget.total)))),

                // selection overlay + gestures
                Positioned(
                  left: leftPx,
                  width: selWidthPx > 0 ? selWidthPx : 0,
                  top: 6,
                  bottom: 6,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {
                      final localX = details.localPosition.dx;
                      if (localX <= handleHit) {
                        _mode = _HandleDragMode.left;
                      } else if (localX >= selWidthPx - handleHit) {
                        _mode = _HandleDragMode.right;
                      } else {
                        _mode = _HandleDragMode.move;
                      }
                    },
                    onPanUpdate: (details) {
                      final dx = details.delta.dx;
                      final secondsDelta = _pxToSec(dx, width);

                      if (_mode == _HandleDragMode.left) {
                        final newStart = (widget.start + secondsDelta).clamp(0.0, widget.end - widget.minSelection);
                        widget.onStartChanged(newStart);
                      } else if (_mode == _HandleDragMode.right) {
                        final newEnd = (widget.end + secondsDelta).clamp(widget.start + widget.minSelection, widget.total);
                        widget.onEndChanged(newEnd);
                      } else if (_mode == _HandleDragMode.move) {
                        widget.onMoveBy(secondsDelta);
                      }
                    },
                    onPanEnd: (details) {
                      _mode = _HandleDragMode.none;
                    },
                    child: AnimatedContainer(
                      duration: _animDur,
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [onPrimary.withAlpha(111), onPrimary.withAlpha(111)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(color: primary.withAlpha(111)),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Semantics(
                              label: 'Start handle',
                              hint: 'Drag to change start time',
                              child: Container(
                                width: 18,
                                decoration: BoxDecoration(
                                  color: primary.withAlpha(246),
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 3,
                                    height: 18,
                                    decoration: BoxDecoration(color: onPrimary.withAlpha(246), borderRadius: BorderRadius.circular(2)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Semantics(
                              label: 'End handle',
                              hint: 'Drag to change end time',
                              child: Container(
                                width: 18,
                                decoration: BoxDecoration(
                                  color: primary.withAlpha(246),
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 3,
                                    height: 18,
                                    decoration: BoxDecoration(color: onPrimary.withAlpha(246), borderRadius: BorderRadius.circular(2)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // left hit zone
                if (selWidthPx > 0)
                  Positioned(
                    left: (leftPx - handleHit / 2).clamp(0.0, width),
                    top: 0,
                    width: (handleHit).clamp(0.0, width),
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        final secondsDelta = _pxToSec(details.delta.dx, width);
                        final candidate = (widget.start + secondsDelta).clamp(0.0, widget.end - widget.minSelection);
                        widget.onStartChanged(candidate);
                      },
                    ),
                  ),

                // right hit zone
                if (selWidthPx > 0)
                  Positioned(
                    left: (leftPx + selWidthPx - handleHit / 2).clamp(0.0, width - handleHit),
                    top: 0,
                    width: (handleHit).clamp(0.0, width),
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        final secondsDelta = _pxToSec(details.delta.dx, width);
                        final candidate = (widget.end + secondsDelta).clamp(widget.start + widget.minSelection, widget.total);
                        widget.onEndChanged(candidate);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
