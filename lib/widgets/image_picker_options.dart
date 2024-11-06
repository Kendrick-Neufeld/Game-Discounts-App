import 'package:flutter/material.dart';
import '../controllers/choose_picture_controller.dart';
import 'package:provider/provider.dart';

void showImagePickerOptions(BuildContext context) {
  final imagePickerController = Provider.of<ImagePickerController>(context, listen: false);

  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Photo Library'),
              onTap: () async {
                await imagePickerController.imgFromGallery();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () async {
                await imagePickerController.imgFromCamera();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}