import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:social_media_app/cubit/story_cubit/story_cubit.dart';
import 'package:video_player/video_player.dart';

import '../../commons/widgets/stickers_gridview.dart';
import '../../materials/app_colors.dart';

class EditStoryScreen extends StatefulWidget {
  static const String route = 'EditStoryScreen';

  const EditStoryScreen({super.key});

  @override
  State<EditStoryScreen> createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends State<EditStoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  final bool _useMaterialDesign = platformDesignMode == ImageEditorDesignMode.material;

  final WhatsAppHelper _whatsAppHelper = WhatsAppHelper();

  ProVideoController? _proVideoController;
  late VideoPlayerController _videoController;
  late VideoMetadata _videoMetadata;

  final _editorKey = GlobalKey<ProImageEditorState>();
  final _outputFormat = VideoOutputFormat.mp4;
  final _taskId = DateTime.now().microsecondsSinceEpoch.toString();
  String? _outputPath;
  bool isVideo = false;

  final _videoConfigs = const VideoEditorConfigs(
    initialMuted: false,
    initialPlay: true,
    isAudioSupported: true,
    style: VideoEditorStyle(trimBarHeight: 0),
    controlsPosition: VideoEditorControlPosition.bottom,
    widgets: VideoEditorWidgets(infoBanner: null, trimDurationInfo: null),
  );

  void openWhatsAppStickerEditor(ProImageEditorState editor) async {
    editor.removeKeyEventListener();

    Layer? layer;
    if (_useMaterialDesign) {
      layer = await editor.openPage(WhatsAppStickerPage(configs: editor.configs, callbacks: editor.callbacks));
    } else {
      layer = await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black12,
        showDragHandle: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder:
            (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  clipBehavior: Clip.hardEdge,
                  child: WhatsAppStickerPage(configs: editor.configs, callbacks: editor.callbacks),
                ),
              ),
            ),
      );
    }

    editor.initKeyEventListener();
    if (layer == null || !mounted) return;

    if (layer.runtimeType != WidgetLayer) {
      layer.scale = editor.configs.emojiEditor.initScale;
    }

    editor.addLayer(layer);
  }

  int _calculateEmojiColumns(BoxConstraints constraints) => max(1, (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1).floor();

  @override
  void initState() {
    super.initState();
    if (context.read<StoryCubit>().state.mediaType == 'video') {
      _load();
    }
  }

  Future<void> _load() async {
    var cubit = context.read<StoryCubit>();

    setState(() {});

    _videoMetadata = await ProVideoEditor.instance.getMetadata(EditorVideo.file(cubit.state.storyMedia));

    _videoController = VideoPlayerController.file(cubit.state.storyMedia!);
    await _videoController.initialize();

    // set âm lượng ban đầu
    await _videoController.setVolume(1);

    // set trạng thái play/pause ban đầu
    await _videoController.play();

    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: _videoMetadata.resolution,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
    );

    setState(() {
      isVideo = true;
    });
  }

  Future<void> _generateVideo(CompleteParameters parameters) async {
    final targetAspectRatio = 9 / 16;
    final videoW = _videoMetadata.resolution.width;
    final videoH = _videoMetadata.resolution.height;

    ExportTransform? transform;

    if (parameters.isTransformed) {
      // User đã crop
      transform = ExportTransform(
        width: parameters.cropWidth,
        height: parameters.cropHeight,
        rotateTurns: parameters.rotateTurns,
        x: parameters.cropX,
        y: parameters.cropY,
        flipX: parameters.flipX,
        flipY: parameters.flipY,
      );
    } else {
      // Auto crop theo aspectRatio của cubit
      transform = _autoCropTransform(videoW.floor(), videoH.floor(), targetAspectRatio);
    }

    final exportModel = RenderVideoModel(
      id: _taskId,
      video: EditorVideo.file(context.read<StoryCubit>().state.storyMedia),
      outputFormat: _outputFormat,
      enableAudio: _proVideoController?.isAudioEnabled ?? true,
      imageBytes: parameters.layers.isNotEmpty ? parameters.image : null,
      blur: parameters.blur,
      colorMatrixList: parameters.colorFilters,
      startTime: parameters.startTime,
      endTime: parameters.endTime,
      transform: transform,
    );

    final directory = await getTemporaryDirectory();
    final now = DateTime.now().millisecondsSinceEpoch;
    _outputPath = await ProVideoEditor.instance.renderVideoToFile('${directory.path}/edited_video_$now.mp4', exportModel);
    if (!mounted) return;
    context.read<StoryCubit>().saveChange(_outputPath!);
  }

  ExportTransform _autoCropTransform(int videoW, int videoH, double targetAspectRatio) {
    final currentRatio = videoW / videoH;

    int cropW, cropH, offsetX, offsetY;
    if (currentRatio > targetAspectRatio) {
      // Video quá rộng => crop ngang
      cropH = videoH;
      cropW = (videoH * targetAspectRatio).toInt();
      offsetX = ((videoW - cropW) / 2).toInt();
      offsetY = 0;
    } else {
      // Video quá cao => crop dọc
      cropW = videoW;
      cropH = (videoW / targetAspectRatio).toInt();
      offsetX = 0;
      offsetY = ((videoH - cropH) / 2).toInt();
    }

    return ExportTransform(width: cropW, height: cropH, x: offsetX, y: offsetY, rotateTurns: 0, flipX: false, flipY: false);
  }

  Widget _buildVideoPlayer() {
    return Center(child: VideoPlayer(_videoController));
  }

  @override
  void dispose() {
    if (isVideo) {
      _proVideoController?.dispose();
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, state) {
        var cubit = context.read<StoryCubit>();
        return LayoutBuilder(
          builder: (context, constraints) {
            return
              cubit.state.mediaType == 'image'
                ? ProImageEditor.file(
                  cubit.state.storyMedia,
                  // key: editorKey,
                  callbacks: ProImageEditorCallbacks(
                    mainEditorCallbacks: MainEditorCallbacks(onScaleStart: _whatsAppHelper.onScaleStart, onTap: () => FocusScope.of(context).unfocus()),
                    stickerEditorCallbacks: StickerEditorCallbacks(
                      onSearchChanged: (value) {
                        debugPrint(value);
                      },
                    ),
                    onImageEditingComplete: (results) async {
                      final dir = await getTemporaryDirectory();
                      final file = File("${dir.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.png");
                      await file.writeAsBytes(results);
                      cubit.saveChange(file.path);
                    },
                  ),
                  configs: ProImageEditorConfigs(
                    designMode: platformDesignMode,
                    mainEditor: MainEditorConfigs(
                      enableZoom: true,
                      widgets: MainEditorWidgets(
                        appBar: (editor, rebuildStream) => null,
                        bottomBar: (editor, rebuildStream, key) => null,
                        wrapBody: (editor, rebuildStream, content) {
                          return Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                      clipBehavior: Clip.hardEdge,
                                      transform: Matrix4.diagonal3Values(
                                        1 / constraints.maxHeight * (constraints.maxHeight - _whatsAppHelper.filterShowHelper * 2),
                                        1 / constraints.maxHeight * (constraints.maxHeight - _whatsAppHelper.filterShowHelper * 2),
                                        1,
                                      ),
                                      child: AspectRatio(aspectRatio: 9 / 16, child: content),
                                    ),
                                    if (true) ..._buildWhatsAppWidgets(editor),
                                  ],
                                ),
                              ),
                              // Row custom ở dưới cùng
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => editor.doneEditing(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          margin: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(color: AppColors.textMutedLight, borderRadius: BorderRadius.circular(16)),
                                          child: Center(child: Text('data')),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => editor.doneEditing(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          margin: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                                          child: Center(child: Text('data')),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    paintEditor: PaintEditorConfigs(
                      style: const PaintEditorStyle(initialColor: Color.fromARGB(255, 129, 218, 88), initialStrokeWidth: 5),
                      widgets: PaintEditorWidgets(
                        appBar: (paintEditor, rebuildStream) => null,
                        bottomBar: (paintEditor, rebuildStream) => null,
                        colorPicker: (paintEditor, rebuildStream, currentColor, setColor) => null,
                        bodyItems: _buildPaintEditorBody,
                      ),
                    ),
                    textEditor: TextEditorConfigs(
                      customTextStyles: [
                        GoogleFonts.roboto(),
                        GoogleFonts.averiaLibre(),
                        GoogleFonts.lato(),
                        GoogleFonts.comicNeue(),
                        GoogleFonts.actor(),
                        GoogleFonts.odorMeanChey(),
                        GoogleFonts.nabla(),
                      ],
                      widgets: TextEditorWidgets(
                        appBar: (textEditor, rebuildStream) => null,
                        colorPicker: (editor, rebuildStream, currentColor, setColor) => null,
                        bottomBar: (textEditor, rebuildStream) => null,
                        bodyItems: _buildTextEditorBody,
                      ),
                      style: TextEditorStyle(
                        textFieldMargin: EdgeInsets.zero,
                        bottomBarBackground: Colors.transparent,
                        bottomBarMainAxisAlignment: !_useMaterialDesign ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                      ),
                    ),
                    cropRotateEditor: CropRotateEditorConfigs(
                      initAspectRatio: 9 / 16,
                      enableDoubleTap: false,
                      widgets: CropRotateEditorWidgets(
                        appBar: (cropRotateEditor, rebuildStream) => null,
                        bottomBar:
                            (cropRotateEditor, rebuildStream) => ReactiveWidget(
                              stream: rebuildStream,
                              builder:
                                  (_) => WhatsAppCropRotateToolbar(
                                    bottomBarColor: const Color(0xFF303030),
                                    configs: cropRotateEditor.configs,
                                    onCancel: cropRotateEditor.close,
                                    onRotate: cropRotateEditor.rotate,
                                    onDone: cropRotateEditor.done,
                                    onReset: cropRotateEditor.reset,
                                    openAspectRatios: cropRotateEditor.openAspectRatioOptions,
                                  ),
                            ),
                      ),
                      style: const CropRotateEditorStyle(
                        cropCornerColor: Colors.white,
                        helperLineColor: Colors.white,
                        cropCornerLength: 28,
                        cropCornerThickness: 3,
                      ),
                    ),
                    filterEditor: FilterEditorConfigs(
                      fadeInUpDuration: Duration.zero,
                      filterList: [
                        const FilterModel(
                          name: 'None',
                          filters: [
                            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                          ],
                        ),
                        FilterModel(
                          name: 'Pop',
                          filters: [ColorFilterAddons.colorOverlay(255, 225, 80, 0.08), ColorFilterAddons.saturation(0.1), ColorFilterAddons.contrast(0.05)],
                        ),
                        FilterModel(
                          name: 'B&W',
                          filters: [ColorFilterAddons.grayscale(), ColorFilterAddons.colorOverlay(100, 28, 210, 0.03), ColorFilterAddons.brightness(0.1)],
                        ),
                        FilterModel(name: 'Cool', filters: [ColorFilterAddons.addictiveColor(0, 0, 20)]),
                        FilterModel(name: 'Chrome', filters: [ColorFilterAddons.contrast(0.15), ColorFilterAddons.saturation(0.2)]),
                        FilterModel(name: 'Film', filters: [ColorFilterAddons.brightness(.05), ColorFilterAddons.saturation(-0.03)]),
                      ],
                      widgets: FilterEditorWidgets(
                        filterButton: (filter, isSelected, scaleFactor, onSelectFilter, editorImage, filterKey) {
                          return WhatsAppFilterBtn(
                            filter: filter,
                            isSelected: isSelected,
                            onSelectFilter: () {
                              onSelectFilter.call();
                            },
                            editorImage: editorImage,
                            filterKey: filterKey,
                            scaleFactor: scaleFactor,
                          );
                        },
                      ),
                      style: const FilterEditorStyle(filterListSpacing: 7, filterListMargin: EdgeInsets.fromLTRB(8, 15, 8, 10)),
                    ),
                    emojiEditor: EmojiEditorConfigs(
                      checkPlatformCompatibility: !kIsWeb,
                      style: EmojiEditorStyle(
                        backgroundColor: Colors.transparent,
                        textStyle: DefaultEmojiTextStyle.copyWith(
                          fontFamily: !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
                          fontSize: _useMaterialDesign ? 48 : 30,
                        ),
                        emojiViewConfig: EmojiViewConfig(
                          gridPadding: EdgeInsets.zero,
                          horizontalSpacing: 0,
                          verticalSpacing: 0,
                          recentsLimit: 40,
                          backgroundColor: Colors.transparent,
                          buttonMode: !_useMaterialDesign ? ButtonMode.CUPERTINO : ButtonMode.MATERIAL,
                          loadingIndicator: const Center(child: CircularProgressIndicator()),
                          columns: _calculateEmojiColumns(constraints),
                          emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                          replaceEmojiOnLimitExceed: false,
                        ),
                        bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                      ),
                    ),
                    stickerEditor: StickerEditorConfigs(
                      enabled: true,
                      builder: (addSticker, scrollController) {
                        return StickerMediaGrid(addSticker: addSticker, controller: scrollController);
                      },
                    ),
                    layerInteraction: const LayerInteractionConfigs(style: LayerInteractionStyle(removeAreaBackgroundInactive: Colors.black12)),
                    helperLines: const HelperLineConfigs(
                      style: HelperLineStyle(horizontalColor: Color.fromARGB(255, 129, 218, 88), verticalColor: Color.fromARGB(255, 129, 218, 88)),
                    ),
                  ),
                )
                :
              _proVideoController == null
                ? Center(child: CircularProgressIndicator())
                : ProImageEditor.video(
                  _proVideoController!,
                  key: _editorKey,
                  callbacks: ProImageEditorCallbacks(
                    onCompleteWithParameters: _generateVideo,
                    videoEditorCallbacks: VideoEditorCallbacks(
                      onPause: _videoController.pause,
                      onPlay: _videoController.play,
                      onMuteToggle: (isMuted) => _videoController.setVolume(isMuted ? 0.0 : 1.0),
                      onTrimSpanUpdate: (span) async {
                        await _videoController.pause();
                        await _videoController.seekTo(span.start);
                      },
                      onTrimSpanEnd: (span) async {
                        await _videoController.seekTo(span.start);
                        await _videoController.play();
                      },
                    ),
                  ),
                  configs: ProImageEditorConfigs(
                    designMode: platformDesignMode,
                    videoEditor: _videoConfigs,
                    mainEditor: MainEditorConfigs(
                      enableZoom: true,
                      widgets: MainEditorWidgets(
                        appBar: (editor, rebuildStream) => null,
                        bottomBar: (editor, rebuildStream, key) => null,
                        wrapBody: (editor, rebuildStream, content) {
                          return Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                                      clipBehavior: Clip.hardEdge,
                                      transform: Matrix4.diagonal3Values(
                                        1 / constraints.maxHeight * (constraints.maxHeight - _whatsAppHelper.filterShowHelper * 2),
                                        1 / constraints.maxHeight * (constraints.maxHeight - _whatsAppHelper.filterShowHelper * 2),
                                        1,
                                      ),
                                      child: AspectRatio(aspectRatio: 9 / 16, child: content),
                                    ),
                                    if (true) ..._buildWhatsAppWidgets(editor),
                                  ],
                                ),
                              ),
                              // Row custom ở dưới cùng
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => editor.doneEditing(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          margin: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(color: AppColors.textMutedLight, borderRadius: BorderRadius.circular(16)),
                                          child: Center(child: Text('data')),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => editor.doneEditing(),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          margin: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                                          child: Center(child: Text('data')),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    paintEditor: PaintEditorConfigs(
                      style: const PaintEditorStyle(initialColor: Color.fromARGB(255, 129, 218, 88), initialStrokeWidth: 5),
                      widgets: PaintEditorWidgets(
                        appBar: (paintEditor, rebuildStream) => null,
                        bottomBar: (paintEditor, rebuildStream) => null,
                        colorPicker: (paintEditor, rebuildStream, currentColor, setColor) => null,
                        bodyItems: _buildPaintEditorBody,
                      ),
                    ),
                    textEditor: TextEditorConfigs(
                      customTextStyles: [
                        GoogleFonts.roboto(),
                        GoogleFonts.averiaLibre(),
                        GoogleFonts.lato(),
                        GoogleFonts.comicNeue(),
                        GoogleFonts.actor(),
                        GoogleFonts.odorMeanChey(),
                        GoogleFonts.nabla(),
                      ],
                      widgets: TextEditorWidgets(
                        appBar: (textEditor, rebuildStream) => null,
                        colorPicker: (editor, rebuildStream, currentColor, setColor) => null,
                        bottomBar: (textEditor, rebuildStream) => null,
                        bodyItems: _buildTextEditorBody,
                      ),
                      style: TextEditorStyle(
                        textFieldMargin: EdgeInsets.zero,
                        bottomBarBackground: Colors.transparent,
                        bottomBarMainAxisAlignment: !_useMaterialDesign ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                      ),
                    ),
                    cropRotateEditor: CropRotateEditorConfigs(
                      initAspectRatio: 9 / 16,
                      enableDoubleTap: false,
                      widgets: CropRotateEditorWidgets(
                        appBar: (cropRotateEditor, rebuildStream) => null,
                        bottomBar:
                            (cropRotateEditor, rebuildStream) => ReactiveWidget(
                              stream: rebuildStream,
                              builder:
                                  (_) => WhatsAppCropRotateToolbar(
                                    bottomBarColor: const Color(0xFF303030),
                                    configs: cropRotateEditor.configs,
                                    onCancel: cropRotateEditor.close,
                                    onRotate: cropRotateEditor.rotate,
                                    onDone: cropRotateEditor.done,
                                    onReset: cropRotateEditor.reset,
                                    openAspectRatios: cropRotateEditor.openAspectRatioOptions,
                                  ),
                            ),
                      ),
                      style: const CropRotateEditorStyle(
                        cropCornerColor: Colors.white,
                        helperLineColor: Colors.white,
                        cropCornerLength: 28,
                        cropCornerThickness: 3,
                      ),
                    ),
                    filterEditor: FilterEditorConfigs(
                      fadeInUpDuration: Duration.zero,
                      filterList: [
                        const FilterModel(
                          name: 'None',
                          filters: [
                            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                          ],
                        ),
                        FilterModel(
                          name: 'Pop',
                          filters: [ColorFilterAddons.colorOverlay(255, 225, 80, 0.08), ColorFilterAddons.saturation(0.1), ColorFilterAddons.contrast(0.05)],
                        ),
                        FilterModel(
                          name: 'B&W',
                          filters: [ColorFilterAddons.grayscale(), ColorFilterAddons.colorOverlay(100, 28, 210, 0.03), ColorFilterAddons.brightness(0.1)],
                        ),
                        FilterModel(name: 'Cool', filters: [ColorFilterAddons.addictiveColor(0, 0, 20)]),
                        FilterModel(name: 'Chrome', filters: [ColorFilterAddons.contrast(0.15), ColorFilterAddons.saturation(0.2)]),
                        FilterModel(name: 'Film', filters: [ColorFilterAddons.brightness(.05), ColorFilterAddons.saturation(-0.03)]),
                      ],
                      widgets: FilterEditorWidgets(
                        filterButton: (filter, isSelected, scaleFactor, onSelectFilter, editorImage, filterKey) {
                          return WhatsAppFilterBtn(
                            filter: filter,
                            isSelected: isSelected,
                            onSelectFilter: () {
                              onSelectFilter.call();
                            },
                            editorImage: editorImage,
                            filterKey: filterKey,
                            scaleFactor: scaleFactor,
                          );
                        },
                      ),
                      style: const FilterEditorStyle(filterListSpacing: 7, filterListMargin: EdgeInsets.fromLTRB(8, 15, 8, 10)),
                    ),
                    emojiEditor: EmojiEditorConfigs(
                      checkPlatformCompatibility: !kIsWeb,
                      style: EmojiEditorStyle(
                        backgroundColor: Colors.transparent,
                        textStyle: DefaultEmojiTextStyle.copyWith(
                          fontFamily: !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
                          fontSize: _useMaterialDesign ? 48 : 30,
                        ),
                        emojiViewConfig: EmojiViewConfig(
                          gridPadding: EdgeInsets.zero,
                          horizontalSpacing: 0,
                          verticalSpacing: 0,
                          recentsLimit: 40,
                          backgroundColor: Colors.transparent,
                          buttonMode: !_useMaterialDesign ? ButtonMode.CUPERTINO : ButtonMode.MATERIAL,
                          loadingIndicator: const Center(child: CircularProgressIndicator()),
                          columns: _calculateEmojiColumns(constraints),
                          emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                          replaceEmojiOnLimitExceed: false,
                        ),
                        bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
                      ),
                    ),
                    stickerEditor: StickerEditorConfigs(
                      enabled: true,
                      builder: (addSticker, scrollController) {
                        return StickerMediaGrid(addSticker: addSticker, controller: scrollController);
                      },
                    ),
                    layerInteraction: const LayerInteractionConfigs(style: LayerInteractionStyle(removeAreaBackgroundInactive: Colors.black12)),
                    helperLines: const HelperLineConfigs(
                      style: HelperLineStyle(horizontalColor: Color.fromARGB(255, 129, 218, 88), verticalColor: Color.fromARGB(255, 129, 218, 88)),
                    ),
                  ),
                );
          },
        );
      },
    );
  }

  List<ReactiveWidget> _buildPaintEditorBody(PaintEditorState paintEditor, Stream<dynamic> rebuildStream) {
    return [
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppPaintBottomBar(
              configs: paintEditor.configs,
              strokeWidth: paintEditor.paintCtrl.strokeWidth,
              initColor: paintEditor.paintCtrl.color,
              onColorChanged: (color) {
                paintEditor.paintCtrl.setColor(color);
                paintEditor.uiPickerStream.add(null);
              },
              onSetLineWidth: paintEditor.setStrokeWidth,
            ),
      ),
      if (!_useMaterialDesign) ReactiveWidget(stream: rebuildStream, builder: (_) => WhatsappPaintColorpicker(paintEditor: paintEditor)),
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppPaintAppBar(
              configs: paintEditor.configs,
              canUndo: paintEditor.canUndo,
              onDone: paintEditor.done,
              onTapUndo: paintEditor.undoAction,
              onClose: paintEditor.close,
              activeColor: paintEditor.activeColor,
            ),
      ),
    ];
  }

  List<ReactiveWidget> _buildTextEditorBody(TextEditorState textEditor, Stream<dynamic> rebuildStream) {
    return [
      /// Color-Picker
      if (_useMaterialDesign)
        ReactiveWidget(
          stream: rebuildStream,
          builder: (_) => Padding(padding: const EdgeInsets.only(top: kToolbarHeight), child: WhatsappTextSizeSlider(textEditor: textEditor)),
        )
      else
        ReactiveWidget(
          stream: rebuildStream,
          builder: (_) => Padding(padding: const EdgeInsets.only(top: kToolbarHeight), child: WhatsappTextColorpicker(textEditor: textEditor)),
        ),

      /// Appbar
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppTextAppBar(
              configs: textEditor.configs,
              align: textEditor.align,
              onDone: textEditor.done,
              onAlignChange: textEditor.toggleTextAlign,
              onBackgroundModeChange: textEditor.toggleBackgroundMode,
            ),
      ),

      /// Bottombar
      ReactiveWidget(
        stream: rebuildStream,
        builder:
            (_) => WhatsAppTextBottomBar(
              configs: textEditor.configs,
              initColor: textEditor.primaryColor,
              onColorChanged: (color) {
                textEditor.primaryColor = color;
              },
              selectedStyle: textEditor.selectedTextStyle,
              onFontChange: textEditor.setTextStyle,
            ),
      ),
    ];
  }

  List<Widget> _buildWhatsAppWidgets(ProImageEditorState editor) {
    return [
      WhatsAppAppBar(
        configs: editor.configs,
        onClose: editor.closeEditor,
        onTapCropRotateEditor: editor.openCropRotateEditor,
        onTapStickerEditor: () => openWhatsAppStickerEditor(editor),
        onTapPaintEditor: editor.openPaintEditor,
        onTapTextEditor: editor.openTextEditor,
        onTapUndo: editor.undoAction,
        canUndo: editor.canUndo,
        openEditor: editor.isSubEditorOpen,
      ),
      WhatsappFilters(editor: editor, whatsAppHelper: _whatsAppHelper),
    ];
  }
}
