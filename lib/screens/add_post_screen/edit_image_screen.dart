import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/utils/crop_aspect_ratios.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';

class EditImageScreen extends StatelessWidget {
  static const String route = 'EditImageScreen';

  const EditImageScreen({super.key});

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
  late Uint8List rawImageBytes;
  Uint8List? editedImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // rawImageBytes =
    //     context.read<PostCubit>().state.selectedAssets[context
    //         .read<PostCubit>()
    //         .state
    //         .selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return ProImageEditor.memory(
          rawImageBytes,
          callbacks: ProImageEditorCallbacks(

          ),
          configs: ProImageEditorConfigs(
            theme: ThemeData.dark(),
            i18n: const I18n(
              textEditor: I18nTextEditor(bottomNavigationBarText: 'Van ban'),
              tuneEditor: I18nTuneEditor(bottomNavigationBarText: 'Chinh sua'),
              filterEditor: I18nFilterEditor(bottomNavigationBarText: 'Bo loc'),
              stickerEditor: I18nStickerEditor(
                bottomNavigationBarText: 'Lop phu',
              ),
              cropRotateEditor: I18nCropRotateEditor(
                bottomNavigationBarText: 'Cat anh',
              ),
            ),
            textEditor: TextEditorConfigs(enabled: true),
            stickerEditor: StickerEditorConfigs(enabled: true),
            filterEditor: FilterEditorConfigs(enabled: true),
            tuneEditor: TuneEditorConfigs(enabled: true),
            cropRotateEditor: CropRotateEditorConfigs(
              enabled: true,
              initAspectRatio:
                  cubit.state.aspectRatio == 1
                      ? CropAspectRatios.ratio1_1
                      : CropAspectRatios.ratio9_16,
              showAspectRatioButton: false,
              style: CropRotateEditorStyle(
                cropCornerThickness: 0,
              ),
              maxWidthFactor: 1.0,
            ),
            paintEditor: PaintEditorConfigs(enabled: false),
            emojiEditor: EmojiEditorConfigs(enabled: false),
            blurEditor: BlurEditorConfigs(enabled: false),
          ),
        );
      },
    );
  }
}
