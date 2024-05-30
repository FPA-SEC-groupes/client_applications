import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryViewModel extends ChangeNotifier  {
  final picker = ImagePicker();
  File? _image;

  File? get image => _image;

  Future<bool> requestGalleryPermission(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Photos Permission'),
          content: const Text('Photos permission should be granted to use this feature. '
              'Would you like to go to app settings to give photos permission?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        )
      );
    }

    return false;
  }

  Future<void> selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }


}