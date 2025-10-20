import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/utils/crop_aspect_ratios.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:social_media_app/commons/enums/load_status.dart';
import 'package:social_media_app/cubit/post_cubit/post_cubit.dart';

import '../../commons/widgets/stickers_gridview.dart';

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
  bool isReCrop = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if(state.loadStatus == LoadStatus.done) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return cubit.state.loadStatus == LoadStatus.loading
            ? Center(child: CircularProgressIndicator())
            : ProImageEditor.file(
          cubit.state.assets[cubit.state.selectedIndex]['file'],
          callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (result) async{
                final croppedImage = await cubit.cropImage(result);
                await cubit.saveImage(croppedImage);
              }
          ),
          configs: ProImageEditorConfigs(
            theme: ThemeData.dark(),
            mainEditor: MainEditorConfigs(
                tools: [
                  SubEditorMode.text,
                  SubEditorMode.paint,
                  SubEditorMode.cropRotate,
                  SubEditorMode.filter,
                  SubEditorMode.sticker,
                  SubEditorMode.emoji,
                  SubEditorMode.tune
                ]
            ),
            stickerEditor: StickerEditorConfigs(
              builder: (addSticker, scrollController) {
                return StickerMediaGrid(addSticker: addSticker, controller: scrollController);
              },
            ),
            cropRotateEditor: CropRotateEditorConfigs(
              initAspectRatio:
              cubit.state.aspectRatio == 1
                  ? CropAspectRatios.ratio1_1
                  : CropAspectRatios.ratio3_4,
              style: CropRotateEditorStyle(cropCornerThickness: 0),
              maxWidthFactor: 1.0,
            ),
          ),
        );
      },
    );
  }
}
