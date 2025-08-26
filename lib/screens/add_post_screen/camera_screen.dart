import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';
import 'package:social_media_app/materials/app_colors.dart';
import 'package:social_media_app/screens/add_post_screen/edit_media_screen.dart';

class CameraScreen extends StatefulWidget {
  static const String route = 'CameraScreen';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => PostCubit(), child: Theme(data: ThemeData.dark(), child: Page()));
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
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high, enableAudio: true);

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 📸 Chụp ảnh
  Future<AssetEntity?> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile xfile = await _controller!.takePicture();

      final asset = await PhotoManager.editor.saveImageWithPath(xfile.path);
      return asset;
    } catch (e) {
      debugPrint("Lỗi chụp ảnh: $e");
      return null;
    }
  }


  /// 🎥 Bắt đầu quay video
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

  /// 🎥 Dừng quay video
  Future<AssetEntity?> _stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return null;

    try {
      final XFile xfile = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);

      final asset = await PhotoManager.editor.saveVideo(File(xfile.path));
      return asset;
    } catch (e) {
      debugPrint("Lỗi dừng quay: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
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
                          onTap: () async {
                            List<AssetEntity> assets = [];
                            final asset = await _takePicture();
                            if (asset != null && context.mounted) {
                              assets.add(asset);
                              Navigator.of(context).pushNamed(EditMediaScreen.route, arguments: {'assets' : assets});
                            }
                          },
                          onLongPressStart: (_) async => await _startVideoRecording(),
                          onLongPressEnd: (_) async {
                            List<AssetEntity> assets = [];
                            final asset = await _stopVideoRecording();
                            if (asset != null && context.mounted) {
                              assets.add(asset);
                              Navigator.of(context).pushNamed(EditMediaScreen.route, arguments: {'assets' : assets});
                            }
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
      },
    );
  }
}