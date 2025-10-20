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
import 'package:social_media_app/screens/add_reel_screen/preview_reel_screen.dart';
import 'package:video_player/video_player.dart';

import '../../commons/enums/load_status.dart';
import '../../commons/widgets/stickers_gridview.dart';
import '../../cubit/reel_bloc/reel_bloc.dart';
import '../../core/mixin/example_helper.dart';
import '../../commons/widgets/instagram_editor_appbar.dart';
import '../../utils/dialogs.dart';
import '../../utils/overlay.dart';

class EditReelScreen extends StatefulWidget {
  static const String route = 'EditReelScreen';

  const EditReelScreen({super.key});

  @override
  State<EditReelScreen> createState() => _EditReelScreenState();
}

class _EditReelScreenState extends State<EditReelScreen> with ExampleHelperState<EditReelScreen> {
  final bool _useMaterialDesign = platformDesignMode == ImageEditorDesignMode.material;

  final _whatsAppHelper = WhatsAppHelper();
  final _captionFocus = FocusNode();

  final _editorKey = GlobalKey<ProImageEditorState>();

  // ProImageEditorState? get _editor => _editorKey.currentState;
  bool _videoInitialized = false;
  bool _doneEditing = false;

  String visibility = 'public';

  // Video related
  ProVideoController? _proVideoController;
  late VideoPlayerController _videoController;
  late VideoMetadata _videoMetadata;

  final _outputFormat = VideoOutputFormat.mp4;
  final String _taskId = DateTime.now().microsecondsSinceEpoch.toString();
  String? _outputPath;

  final _videoConfigs = VideoEditorConfigs(
    initialMuted: false,
    initialPlay: true,
    isAudioSupported: true,
    style: const VideoEditorStyle(trimBarHeight: 0, trimDurationBackground: Colors.transparent, trimDurationTextColor: Colors.transparent),
    controlsPosition: VideoEditorControlPosition.bottom,
    widgets: VideoEditorWidgets(trimBar: SizedBox.shrink(), trimDurationInfo: null, infoBanner: null, trimBarSkeletonLoader: SizedBox.shrink()),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<ReelBloc>();
      if (bloc.state.reelMedia != null) {
        _loadVideo(bloc.state.reelMedia!);
      }
    });
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

    setState(() {
      _videoInitialized = true;
    });
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

    final bloc = context.read<ReelBloc>();

    final exportModel = RenderVideoModel(
      id: _taskId,
      video: EditorVideo.file(bloc.state.reelMedia),
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
    context.read<ReelBloc>().add(SaveChangeEvent(file: File(_outputPath!)));
    _doneEditing = true;
  }

  int _calculateEmojiColumns() => max(1, (_useMaterialDesign ? 6 : 10) / 400 * MediaQuery.sizeOf(context).width - 1).floor();

  @override
  void dispose() {
    _captionFocus.dispose();
    _proVideoController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ReelBloc, ReelState>(
          listenWhen: (prev, cur) => prev.reelMedia != cur.reelMedia,
          listener: (context, state) {
            if (state.reelMedia != null && !_videoInitialized) {
              _loadVideo(state.reelMedia!);
            }
            if(state.reelMedia != null && _doneEditing) {
              Navigator.of(context).pushNamed(ReelPreviewScreen.route, arguments: {'bloc' : context.read<ReelBloc>()});
            }
          },
        ),
        BlocListener<ReelBloc, ReelState>(
          listener: (context, state) async {
            if (state.loadStatus == LoadStatus.loading) {
              LoadingOverlay.show(context);
            } else {
              LoadingOverlay.hide();
            }

            if (state.loadStatus == LoadStatus.error && context.mounted) {
              showErrorDialog(context, state.errorMessage);
            }
          },
        ),
      ],
      child: BlocBuilder<ReelBloc, ReelState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (state.reelMedia == null || _proVideoController == null) {
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
        child: _buildReelShareButton(context: context, onContinue: editor.doneEditing),
      ),
    ];
  }

  Widget _buildReelShareButton({required BuildContext context, VoidCallback? onContinue}) {
    const List<Color> nextButtonGradient = [Color(0xFF3B82F6), Color(0xFF3B82F6)];

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onContinue,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: nextButtonGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Tiếp tục', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_right_alt_sharp, color: Colors.white, size: 26),
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
