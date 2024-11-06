import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerController extends ChangeNotifier {
  File? _image;

  File? get image => _image;

  Future<void> imgFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (pickedImage != null) {
      _image = File(pickedImage.path);
      notifyListeners();
    }
  }

  Future<void> imgFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedImage != null) {
      _image = File(pickedImage.path);
      notifyListeners();
    }
  }
}