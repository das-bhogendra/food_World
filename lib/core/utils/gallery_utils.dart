import 'dart:io';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveAssetsToGallery() async {
  final assetImages = [
    'assets/images/biryani.jpg',
    'assets/images/burger.jpg',
    'assets/images/pasta.jpg',
    'assets/images/pizza.jpg',
    'assets/images/noodles.jpg',
    'assets/images/butterfly_pasta.jpg',
    'assets/images/sandwich.jpg',
    'assets/images/white_rice.jpg',
    'assets/images/fried_rice.jpg',
    'assets/images/chicken.jpg',
    'assets/images/fried_chicken.jpg',
    'assets/images/hotdog.jpg',
    'assets/images/jollof_rice.jpg',
  ];

  final permission = await PhotoManager.requestPermissionExtend();
  if (!permission.isAuth) return;

  final tempDir = await getTemporaryDirectory();

  for (var assetPath in assetImages) {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${tempDir.path}/${assetPath.split("/").last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await PhotoManager.editor.saveImageWithPath(
      file.path,
      title: assetPath.split("/").last,
    );
  }

  print("All assets saved to gallery!");
}
