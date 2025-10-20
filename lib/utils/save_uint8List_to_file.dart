import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<File> saveUint8ListToFile(Uint8List bytes, {String? fileName}) async {
  final dir = await getTemporaryDirectory();

  final name = fileName ?? 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final file = File('${dir.path}/$name');

  await file.writeAsBytes(bytes);

  return file;
}
