import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/materials/app_colors.dart';

class CameraScreen extends StatefulWidget {
  static const String route = 'CameraScreen';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
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
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(firstCamera, ResolutionPreset.high, enableAudio: true);

      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Chụp ảnh
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile xFile = await _controller!.takePicture();

      final String path = xFile.path;
      debugPrint('Chụp ảnh xong, path=$path');

      if (path.isEmpty) {
        if (mounted) Navigator.of(context).pop(null);
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
        debugPrint('File ảnh không tồn tại: $path');
        if (mounted) Navigator.of(context).pop(null);
        return;
      }

      if (!mounted) return;
      // Trả file về caller để caller tự xử lý (upload, save vào gallery, preview...)
      Navigator.of(context).pop({
        'file' : file,
        'mediaType' : 'image'
      });
    } catch (e, st) {
      debugPrint('Lỗi chụp ảnh: $e\n$st');
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  // Bắt đầu quay video
  Future<void> _startVideoRecording() async {
    if (_controller == null || _controller!.value.isRecordingVideo) return;
    try {
      await _initializeControllerFuture;
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint("Lỗi bắt đầu quay: $e");
    }
  }

  // Dừng quay video
  Future<void> _stopVideoRecording() async {
    if (_controller == null) return;

    try {
      if (!_controller!.value.isRecordingVideo) {
        setState(() => _isRecording = false);
        return;
      }

      final XFile xFile = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      final String path = xFile.path;
      debugPrint('Dừng quay, xFile.path = $path');

      if (path.isEmpty) {
        if (mounted) Navigator.of(context).pop(null);
        return;
      }

      final file = File(path);
      if (!await file.exists()) {
        debugPrint('File video không tồn tại: $path');
        if (mounted) Navigator.of(context).pop(null);
        return;
      }

      if (!mounted) return;
      // Trả file về caller (caller sẽ quyết định lưu vào gallery hoặc upload)
      Navigator.of(context).pop({
        'file' : file,
        'mediaType' : 'video'
      });
    } catch (e, st) {
      debugPrint('Lỗi dừng quay: $e\n$st');
      if (mounted) Navigator.of(context).pop(null);
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera full màn hình
                CameraPreview(_controller!),
                // Overlay ở dưới
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await _takePicture();
                      },
                      onLongPressStart: (_) async => await _startVideoRecording(),
                      onLongPressEnd: (_) async {
                        await _stopVideoRecording();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isRecording ? 90 : 70,
                        height: _isRecording ? 90 : 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.image, size: 36, color: AppColors.textLight),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    color: Colors.black.withAlpha(40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close, size: 28, color: AppColors.textLight),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.flash_off, size: 28, color: AppColors.textLight),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.settings, size: 28, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
