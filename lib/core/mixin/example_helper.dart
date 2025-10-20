import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:vibration/vibration.dart';

mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  final editorKey = GlobalKey<ProImageEditorState>();

  Uint8List? editedBytes;

  double? _generationTime;

  DateTime? startEditingTime;

  bool isPreCached = true;

  bool _deviceCanVibrate = false;
  bool _deviceCanCustomVibrate = false;

  @override
  void initState() {
    super.initState();

    Vibration.hasVibrator().then((hasVibrator) async {
      _deviceCanVibrate = hasVibrator;

      if (!hasVibrator || !mounted) return;

      _deviceCanCustomVibrate = await Vibration.hasCustomVibrationsSupport();
    });
  }

  Future<void> onImageEditingStarted() async {
    startEditingTime = DateTime.now();
  }

  Future<void> onImageEditingComplete(Uint8List bytes) async {
    editedBytes = bytes;
    setGenerationTime();
  }

  void setGenerationTime() {
    if (startEditingTime != null) {
      _generationTime = DateTime.now()
          .difference(startEditingTime!)
          .inMilliseconds
          .toDouble();
    }
  }

  void onCloseEditor({
    required EditorMode editorMode,
    bool enablePop = true,
    bool showThumbnail = false,
    ui.Image? rawOriginalImage,
    final ImageGenerationConfigs? generationConfigs,
  }) async {
    if (editorMode != EditorMode.main) return Navigator.pop(context);

    if (editedBytes != null) {
      await precacheImage(MemoryImage(editedBytes!), context);
      if (!mounted) return;

      editorKey.currentState?.isPopScopeDisabled = true;
    }

    if (mounted && enablePop) {
      Navigator.pop(context);
    }
  }

  void preCacheImage({
    String? assetPath,
    String? networkUrl,
    Function()? onDone,
  }) {
    isPreCached = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
          assetPath != null
              ? AssetImage(assetPath)
              : NetworkImage(networkUrl!),
          context)
          .whenComplete(() {
        if (!mounted) return;
        isPreCached = true;
        setState(() {});
        onDone?.call();
      });
    });
  }

  void vibrateLineHit() {
    if (_deviceCanVibrate && _deviceCanCustomVibrate) {
      Vibration.vibrate(duration: 3);
    } else if (!kIsWeb && Platform.isAndroid) {
      Vibration.vibrate();
      Future.delayed(const Duration(milliseconds: 3))
          .whenComplete(Vibration.cancel);
    }
  }
}