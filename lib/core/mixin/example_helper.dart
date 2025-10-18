import 'package:flutter/material.dart';

mixin ExampleHelperState<T extends StatefulWidget> on State<T> {
  final GlobalKey<dynamic> editorKey = GlobalKey();

  void onImageEditingStarted(dynamic editorState) {}
  void onImageEditingComplete(dynamic editorState) {}
  Future<bool> onCloseEditor({required dynamic editorMode}) async => true;
  void vibrateLineHit() {}
}
