import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _openEditor(ProImageEditorFeature feature) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProImageEditor(
              image: ProImage.memory(rawImageBytes),
              config: ProImageEditorConfig(
                // chỉ bật 1 tính năng khi mở
                features: [feature],
              ),
              onImageEditComplete: (bytes) {
                Navigator.pop(context, bytes);
              },
            ),
      ),
    );

    if (result != null && result is Uint8List) {
      setState(() {
        editedImage = result;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rawImageBytes =
        context.read<PostCubit>().state.selectedAssets[context
            .read<PostCubit>()
            .state
            .seletedIndex];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(
      builder: (context, state) {
        var cubit = context.read<PostCubit>();
        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              // Hiển thị ảnh (nếu chưa edit thì lấy ảnh gốc)
              Expanded(
                child: Center(
                  child:
                      editedImage != null
                          ? Image.memory(editedImage!)
                          : Image.memory(rawImageBytes),
                ),
              ),

              // Thanh công cụ
              Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.text_fields),
                      label: const Text("Văn bản"),
                      onPressed: () => _openEditor(ProImageEditorFeature.text),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Lớp phủ"),
                      onPressed:
                          () => _openEditor(ProImageEditorFeature.sticker),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.filter),
                      label: const Text("Bộ lọc"),
                      onPressed:
                          () => _openEditor(ProImageEditorFeature.filter),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Chỉnh sửa"),
                      onPressed: () => _openEditor(ProImageEditorFeature.crop),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
