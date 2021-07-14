# document_picker

# document_picker 0.0.5
A document picker widget comes with latest feature to support in your project design.

## Purpose
The goal of this project is to provide an ultimate widget for selecting/capturing the image.

Normally, you required to spend almost half of the day to write a code for e-KYC or Proof(captured picture, image from gallery, or sign) to upload.

>Here I'm trying to save your time while providing you a package to import and do it whatever you want with it.

![Simulator Screen Shot - iPhone 8 - 2021-06-14 at 13 57 31](https://user-images.githubusercontent.com/24449076/121845740-77568480-cd18-11eb-8f92-49d317555a60.png)
You are required to follow some steps:

## for iOS
Open your `ios/Runner/info.plist` to add permission for Camera and Gallery as: 
- `<key>NSCameraUsageDescription</key>
 	<string>To take photos of your documents for e-KYC and proofs</string>`
- `<key>NSPhotoLibraryUsageDescription</key>
 	<string>To select existing photos of your documents for e-KYC and proofs</string>`

## for Android
> Update sdk version to (minSdkVersion 21) in build.gradle

Open your `android/app/src/main/AndroidManifest.xml` to add permission and activity for Camera, Gallery, and Cropper as:
- ```xml 
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  
  <activity
                     android:name="com.yalantis.ucrop.UCropActivity"
                     android:screenOrientation="portrait"
                     android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>```


## Installing
Add this to your package's pubspec.yaml file:

dependencies: `document_picker: ^0.0.5`


## Sample Usage
```dart
import 'package:document_picker/document_picker.dart';

ProfilePicture(
              url: '',
              editable: true,
              onFileSelection: (file) {},
            ),

            SizedBox(height: 40),

            DocumentSelector(
              url: '',
              editable: true,
              onFileSelection: (File? file) {
                print(file);
              },
              onErrorMessage: (String? message) {
                print(message);
              },
            ),
```


This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
