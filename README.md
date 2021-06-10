# document_picker

# document_picker 0.0.2
A document picker widget comes with latest feature to support in your project design.

## Purpose
The goal of this project is to provide an ultimate widget for selecting/capturing the image.

Normally, you required to spend almost half of the day to write a code for e-KYC or Proof(captured picture, image from gallery, or sign) to upload.

>Here I'm trying to save your time while providing you a package to import and do it whatever you want with it.

![Simulator Screen Shot - iPhone 8 - 2021-05-10 at 15 45 32](https://user-images.githubusercontent.com/24449076/117623774-cbfd6180-b1a6-11eb-8689-ed966274994b.png)

You are required to follow some steps:

## for iOS
Open your `ios/Runner/info.plist` to add permission for Camera and Gallery as: 
- `<key>NSCameraUsageDescription</key>
 	<string>To take photos of your documents for e-KYC and proofs</string>`
- `<key>NSPhotoLibraryUsageDescription</key>
 	<string>To select existing photos of your documents for e-KYC and proofs</string>`

## for Android
Open your `android/app/src/main/AndroidManifest.xml` to add permission for Camera and Gallery as:
- `<uses-permission android:name="android.permission.CAMERA" />`
- `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>`



## Installing
Add this to your package's pubspec.yaml file:

dependencies:
``` document_picker: ^0.0.2 ```


## Sample Usage
```dart
import 'package:document_picker/document_picker.dart';

ImageSelector(
              url: '',
              editable: true,
              onFileSelection: (File? file) {
                print(file);
              },
              onErrorMessage: (String? message) {
                print(message);
              },
            )
```


This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
