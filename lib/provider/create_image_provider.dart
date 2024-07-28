import 'package:flutter/material.dart';
import '../chatbot/image_item.dart';

class CreateImageProvider with ChangeNotifier {
  String? _selectedImagePath;
  int _currentIndex = 0;
  String? _recordingFilePath;
  int? _selectedIndex;
  bool _isEditing = false;
  List<ImageItem> _imageItems = [];

  List<String> _imagePaths = [
    'assets/neutral.png',
    'assets/neutral_girl.png',
    'assets/neutral.png',
  ];

  String? get selectedImagePath => _selectedImagePath;
  int get currentIndex => _currentIndex;
  String? get recordingFilePath => _recordingFilePath;
  List<String> get imagePaths => _imagePaths;
  int? get selectedIndex => _selectedIndex;
  bool get isEditing => _isEditing;
  List<ImageItem> get imageItems => _imageItems;

  void setImagePath(int index) {
    _currentIndex = index;
    _selectedImagePath = _imagePaths[index];
    notifyListeners();
  }

  void setRecordingFilePath(String path) {
    _recordingFilePath = path;
    notifyListeners();
  }

  void updateImagePaths(List<String> newPaths) {
    _imagePaths = newPaths;
    notifyListeners();
  }

  void updateImagePath(String newPath) {
    _selectedImagePath = newPath;
    notifyListeners();
  }

  void setImageItems(List<ImageItem> items) {
    _imageItems = items;
    notifyListeners();
  }

  void addImageItem(ImageItem item) {
    _imageItems.add(item);
    notifyListeners();
  }

  void removeImageItem(int index) {
    _imageItems.removeAt(index);
    if (_selectedIndex == index) {
      _selectedIndex = _imageItems.isNotEmpty ? (_selectedIndex! > 0 ? _selectedIndex! - 1 : null) : null;
    }
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }
}
