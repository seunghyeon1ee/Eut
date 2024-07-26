import 'package:flutter/material.dart';

class ImageItem {
  final String name;
  final String imagePath;
  final Map<String,String> emotionImages;

  ImageItem({
    required this.name,
    required this.imagePath,
    required this.emotionImages,
  });

  // copyWith 메소드 추가
  ImageItem copyWith({
    String? name,
    String? imagePath,
  }) {
    return ImageItem(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath, emotionImages: {},
    );
  }
}
