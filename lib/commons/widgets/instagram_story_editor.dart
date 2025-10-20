import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/designs/frosted_glass/widgets/appbar/frosted_glass_filter_appbar.dart';
import 'package:pro_image_editor/designs/whatsapp/whatsapp.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'stickers_gridview.dart';
import '../enums/load_status.dart';
import '../../cubit/main_cubit/main_cubit.dart';
import '../../cubit/story_bloc/story_bloc.dart';
import '../../utils/overlay.dart';
import '../../utils/dialogs.dart';
import '/core/mixin/example_helper.dart';
import 'instagram_editor_appbar.dart';
import '../../screens/main_screen/main_screen.dart';

class InstagramStoryEditor extends StatefulWidget {
  static const String route = 'InstagramStoryEditor';

  const InstagramStoryEditor({super.key});

  @override
  State<InstagramStoryEditor> createState() => _InstagramStoryEditorState();
}

class _InstagramStoryEditorState extends State<InstagramStoryEditor> with ExampleHelperState<InstagramStoryEditor> {
  final bool _useMaterialDesign = platformDesignMode == ImageEditorDesignMode.material;

  final _whatsAppHelper = WhatsAppHelper();
  final _captionFocus = FocusNode();

  final _editorKey = GlobalKey<ProImageEditorState>();

  // ProImageEditorState? get _editor => _editorKey.currentState;

  String visibility = 'public';

  // Video related
  ProVideoController? _proVideoController;
  late VideoPlayerController _videoController;
  late VideoMetadata _videoMetadata;
  bool isVideo = false;

  final _outputFormat = VideoOutputFormat.mp4;
  final String _taskId = DateTime.now().microsecondsSinceEpoch.toString();
  String? _outputPath;

  final _videoConfigs = const VideoEditorConfigs(
    initialMuted: false,
    initialPlay: true,
    isAudioSupported: true,
    style: VideoEditorStyle(trimBarHeight: 0),
    controlsPosition: VideoEditorControlPosition.bottom,
    widgets: VideoEditorWidgets(infoBanner: null, trimDurationInfo: null),
  );

  ProImageEditorCallbacks get _callbacks => ProImageEditorCallbacks(
    onImageEditingStarted: onImageEditingStarted,
    onImageEditingComplete: onImageEditingComplete,
    onCloseEditor: (editorMode) => onCloseEditor(editorMode: editorMode),
    mainEditorCallbacks: MainEditorCallbacks(
      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
      onScaleStart: _whatsAppHelper.onScaleStart,
      // onScaleUpdate: (details) {
      //   // truyền editor nếu có
      //   _whatsAppHelper.onScaleUpdate(details, _editor!);
      // },
      // onScaleEnd: (details) => _whatsAppHelper.onScaleEnd(details, _editor!),
      onTap: () => FocusScope.of(context).unfocus(),
    ),
    stickerEditorCallbacks: StickerEditorCallbacks(
      onSearchChanged: (value) {
        debugPrint(value);
      },
    ),
  );

  late final _mainEditorConfigs = MainEditorConfigs(
    enableZoom: true,
    tools: [
      SubEditorMode.paint,
      SubEditorMode.text,
      SubEditorMode.cropRotate,
      SubEditorMode.tune,
      SubEditorMode.filter,
      SubEditorMode.blur,
      SubEditorMode.emoji,
      SubEditorMode.sticker,
    ],
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
                      1 / editor.sizesManager.bodySize.height * (editor.sizesManager.bodySize.height - _whatsAppHelper.filterShowHelper * 2),
                      1 / editor.sizesManager.bodySize.height * (editor.sizesManager.bodySize.height - _whatsAppHelper.filterShowHelper * 2),
                      1,
                    ),
                    child: AspectRatio(aspectRatio: 9 / 16, child: content),
                  ),
                  if (!editor.isLayerBeingTransformed) ..._buildWhatsAppWidgets(editor),
                ],
              ),
            ),
            // Bạn có thể chèn widget cố định phía dưới nếu cần
          ],
        );
      },
    ),
  );

  late final _paintEditorConfigs = PaintEditorConfigs(
    style: const PaintEditorStyle(initialColor: Color.fromARGB(255, 129, 218, 88), initialStrokeWidth: 5),
    widgets: PaintEditorWidgets(
      appBar: (paintEditor, rebuildStream) => null,
      bottomBar: (paintEditor, rebuildStream) => null,
      colorPicker: (paintEditor, rebuildStream, currentColor, setColor) => null,
      bodyItems: _buildPaintEditorBody,
    ),
  );

  late final _textEditorConfigs = TextEditorConfigs(
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
  );

  late final _filterEditorConfigs = FilterEditorConfigs(
    style: const FilterEditorStyle(filterListSpacing: 7, filterListMargin: EdgeInsets.fromLTRB(8, 15, 8, 10)),
    widgets: FilterEditorWidgets(
      slider:
          (editorState, rebuildStream, value, onChanged, onChangeEnd) => ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => Slider(onChanged: onChanged, onChangeEnd: onChangeEnd, value: value, activeColor: Colors.blue.shade200),
          ),
      appBar: (filterEditor, rebuildStream) => null,
      bodyItems: (filterEditor, rebuildStream) => [ReactiveWidget(stream: rebuildStream, builder: (_) => FrostedGlassFilterAppbar(filterEditor: filterEditor))],
    ),
  );

  late final _cropEditorConfigs = CropRotateEditorConfigs(
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
    style: const CropRotateEditorStyle(cropCornerColor: Colors.white, helperLineColor: Colors.white, cropCornerLength: 28, cropCornerThickness: 3),
  );

  late final _emojiEditorConfigs = EmojiEditorConfigs(
    checkPlatformCompatibility: !kIsWeb,
    style: EmojiEditorStyle(
      backgroundColor: Colors.transparent,
      textStyle: DefaultEmojiTextStyle.copyWith(fontFamily: !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily, fontSize: _useMaterialDesign ? 48 : 30),
      emojiViewConfig: EmojiViewConfig(
        gridPadding: EdgeInsets.zero,
        horizontalSpacing: 0,
        verticalSpacing: 0,
        recentsLimit: 40,
        backgroundColor: Colors.transparent,
        buttonMode: !_useMaterialDesign ? ButtonMode.CUPERTINO : ButtonMode.MATERIAL,
        loadingIndicator: const Center(child: CircularProgressIndicator()),
        columns: _calculateEmojiColumns(),
        emojiSizeMax: !_useMaterialDesign ? 32 : 64,
        replaceEmojiOnLimitExceed: false,
      ),
      bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
    ),
  );

  late final _stickerEditorConfigs = StickerEditorConfigs(
    builder: (addSticker, scrollController) => StickerMediaGrid(addSticker: addSticker, controller: scrollController),
  );

  late final _layerInteractionConfigs = const LayerInteractionConfigs(
    enableLayerDragSelection: false,
    style: LayerInteractionStyle(removeAreaBackgroundInactive: Colors.black12),
  );

  late final _helperLineConfigs = const HelperLineConfigs(
    style: HelperLineStyle(horizontalColor: Color.fromARGB(255, 129, 218, 88), verticalColor: Color.fromARGB(255, 129, 218, 88)),
  );

  late var _configs = ProImageEditorConfigs(
    designMode: platformDesignMode,
    mainEditor: _mainEditorConfigs,
    paintEditor: _paintEditorConfigs,
    textEditor: _textEditorConfigs,
    cropRotateEditor: _cropEditorConfigs,
    filterEditor: _filterEditorConfigs,
    emojiEditor: _emojiEditorConfigs,
    stickerEditor: _stickerEditorConfigs,
    layerInteraction: _layerInteractionConfigs,
    helperLines: _helperLineConfigs,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<StoryBloc>();
      if (bloc.state.mediaType == 'video' && bloc.state.storyMedia != null) {
        _loadVideo(bloc.state.storyMedia!);
      } else {
        _buildConfigs();
      }
    });
  }

  void _buildConfigs() {
    _configs = ProImageEditorConfigs(
      designMode: platformDesignMode,
      mainEditor: _mainEditorConfigs,
      paintEditor: _paintEditorConfigs,
      textEditor: _textEditorConfigs,
      cropRotateEditor: _cropEditorConfigs,
      filterEditor: _filterEditorConfigs,
      emojiEditor: _emojiEditorConfigs,
      stickerEditor: _stickerEditorConfigs,
      layerInteraction: _layerInteractionConfigs,
      helperLines: _helperLineConfigs,
    );
  }

  Future<void> _loadVideo(File file) async {
    // load metadata and setup controllers
    _videoMetadata = await ProVideoEditor.instance.getMetadata(EditorVideo.file(file));
    _videoController = VideoPlayerController.file(file);
    await _videoController.initialize();
    await _videoController.setVolume(1);
    await _videoController.setLooping(true);
    await _videoController.play();

    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: _videoMetadata.resolution,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
    );

    if (mounted) {
      setState(() {
        isVideo = true;
      });
    }
  }

  Widget _buildVideoPlayer() {
    return Center(child: VideoPlayer(_videoController));
  }

  Future<void> _generateVideo(CompleteParameters parameters) async {
    ExportTransform? transform;
    if (parameters.isTransformed) {
      transform = ExportTransform(
        width: parameters.cropWidth,
        height: parameters.cropHeight,
        rotateTurns: parameters.rotateTurns,
        x: parameters.cropX,
        y: parameters.cropY,
        flipX: parameters.flipX,
        flipY: parameters.flipY,
      );
    }

    final bloc = context.read<StoryBloc>();

    final exportModel = RenderVideoModel(
      id: _taskId,
      video: EditorVideo.file(bloc.state.storyMedia),
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
    context.read<StoryBloc>().add(SaveChangeEvent(_outputPath!));
  }

  @override
  Future<void> onImageEditingComplete(Uint8List result) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/edited_image_${DateTime.now().millisecondsSinceEpoch}.png");
    await file.writeAsBytes(result);
    if (!mounted) return;
    context.read<StoryBloc>().add(SaveChangeEvent(file.path));
  }

  int _calculateEmojiColumns() => max(1, (_useMaterialDesign ? 6 : 10) / 400 * MediaQuery.sizeOf(context).width - 1).floor();

  @override
  void dispose() {
    _captionFocus.dispose();
    if (isVideo) {
      _proVideoController?.dispose();
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StoryBloc, StoryState>(
          listenWhen: (prev, cur) => prev.storyMedia != cur.storyMedia,
          listener: (context, state) {
            if (state.mediaType == 'video' && state.storyMedia != null) {
              _loadVideo(state.storyMedia!);
            }
            final expiresAt = DateTime.now().add(const Duration(days: 1));
            if (state.storyMedia != null) {
              context.read<StoryBloc>().add(CreateStoryEvent(file: state.storyMedia!, expiresAt: expiresAt, visibility: visibility));
            }
          },
        ),
        BlocListener<StoryBloc, StoryState>(
          listener: (context, state) async {
            if (state.loadStatus == LoadStatus.loading) {
              LoadingOverlay.show(context);
            } else {
              LoadingOverlay.hide();
            }

            if (state.loadStatus == LoadStatus.done && state.currentStory != null) {
              final result = await showNotificationDialog(context, message: 'Create Story successfully!');
              if (result == true && context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(MainScreen.route, (route) => false);
              }
            }

            if (state.loadStatus == LoadStatus.error && context.mounted) {
              showErrorDialog(context, state.errorMessage);
            }
          },
        ),
      ],
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (state.mediaType == 'video' && state.storyMedia != null) {
                if (_proVideoController == null || !isVideo) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ProImageEditor.video(
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
                    mainEditorCallbacks: MainEditorCallbacks(
                      helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
                      onScaleStart: _whatsAppHelper.onScaleStart,
                      // onScaleUpdate: (details) => _whatsAppHelper.onScaleUpdate(details, _editor),
                      // onScaleEnd: (details) => _whatsAppHelper.onScaleEnd(details, _editor),
                      onTap: () => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  configs: ProImageEditorConfigs(
                    designMode: platformDesignMode,
                    videoEditor: _videoConfigs,
                    mainEditor: _mainEditorConfigs,
                    paintEditor: _paintEditorConfigs,
                    textEditor: _textEditorConfigs,
                    cropRotateEditor: _cropEditorConfigs,
                    filterEditor: _filterEditorConfigs,
                    emojiEditor: _emojiEditorConfigs,
                    stickerEditor: _stickerEditorConfigs,
                    layerInteraction: _layerInteractionConfigs,
                    helperLines: _helperLineConfigs,
                  ),
                );
              }

              return ProImageEditor.file(state.storyMedia, key: _editorKey, callbacks: _callbacks, configs: _configs);
            },
          );
        },
      ),
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
      InstagramEditorAppbar(
        configs: editor.configs,
        onClose: editor.closeEditor,
        onTapCropRotateEditor: editor.openCropRotateEditor,
        onTapStickerEditor: () => openWhatsAppStickerEditor(editor),
        onTapPaintEditor: editor.openPaintEditor,
        onTapTextEditor: editor.openTextEditor,
        onTapFilterEditor: editor.openFilterEditor,
        onTapUndo: editor.undoAction,
        canUndo: editor.canUndo,
        openEditor: editor.isSubEditorOpen,
      ),
      Positioned(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
        left: 0,
        right: 0,
        child: _buildStoryShareButton(
          context: context,
          onShareStory: editor.doneEditing,
          onShareCloseFriends: () {
            editor.doneEditing();
            visibility = 'close_friends';
          },
        ),
      ),
    ];
  }

  Widget _buildStoryShareButton({
    required BuildContext context,
    VoidCallback? onShareCloseFriends,
    VoidCallback? onShareStory,
    bool isLoadingCloseFriends = false,
    bool isLoadingStory = false,
  }) {
    const List<Color> instaGradient = [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF), Color(0xFF515BD4)];

    const List<Color> closeFriendsGradient = [Color(0xFF32D74B), Color(0xFF34C759)];

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Row(
        children: [
          // Nút "Chia sẻ lên Story"
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoadingStory ? null : onShareStory,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: instaGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(61), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child:
                    isLoadingStory
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: context.read<MainCubit>().state.profile!.avatarUrl ?? '',
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: Colors.grey[300], width: 32, height: 32),
                            errorWidget: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.person, size: 32)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Story', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nút "Chia sẻ cho bạn thân"
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoadingCloseFriends ? null : onShareCloseFriends,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: closeFriendsGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child:
                    isLoadingCloseFriends
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 26),
                        const SizedBox(width: 8),
                        Text('Bạn thân', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
