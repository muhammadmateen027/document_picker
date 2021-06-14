import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Services {
  Services._();

  static Future<Null> cropImage(File? imageFile,
      {Function(File?)? onCrop}) async {
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile!.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop image',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      iosUiSettings: IOSUiSettings(title: 'Crop image'),
    );

    if (croppedFile != null) {
      onCrop!(croppedFile);
    }
  }

  static Future<bool> checkPermission(ImageSource imageSource,
      {Function(Permission?)? permissionError}) async {
    PermissionStatus status;

    if (imageSource == ImageSource.camera) {
      status = await Permission.camera.status;

      if (status.isDenied) {
        await Permission.camera.request();
        return false;
      }

      if (status.isPermanentlyDenied || status.isRestricted) {
        permissionError!(Permission.camera);
        return false;
      }
    }

    status = await Permission.photos.status;

    if (status.isPermanentlyDenied || status.isRestricted) {
      permissionError!(Permission.photos);
      return false;
    }

    await Permission.photos.request();
    return true;
  }

  static Future<void> retrieveLostData(
    final picker, {
    required Function(File?) onLoaded,
    Function(String)? onError,
  }) async {
    final LostData response = await picker.getLostData();
    if (response.isEmpty) {
      return;
    }

    if (response.file == null) {
      onError!(response.exception!.code);
      return;
    }

    if (response.type == RetrieveType.video) {
      return;
    }

    onLoaded(File(response.file!.path));
  }
}
