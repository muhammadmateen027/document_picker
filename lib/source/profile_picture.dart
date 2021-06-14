import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'profile_view.dart';
import 'services.dart';

class ProfilePicture extends StatefulWidget {
  final bool cameraVisible, galleryVisible;
  final String? imageAsset;
  final String url;
  final Function(File? file) onFileSelection;
  final double height;
  final double width;
  final bool editable;
  final BoxShape shape;
  String cameraPermissionErrorMessage;
  String galleryPermissionErrorMessage;
  Function(String?)? onErrorMessage;
  String label;
  String imageNotSelectedMessage;

  ProfilePicture({
    Key? key,
    required this.editable,
    required this.url,
    required this.onFileSelection,
    this.cameraVisible = true,
    this.galleryVisible = true,
    this.imageAsset = 'assets/images/person.png',
    this.height = 140,
    this.width = 140,
    this.shape = BoxShape.rectangle,
    this.onErrorMessage,
    this.label = 'Select',
    this.cameraPermissionErrorMessage =
    'Please allow camera permission from Settings',
    this.galleryPermissionErrorMessage =
    'Please allow gallery permission from Settings',
    this.imageNotSelectedMessage = 'You have not yet picked/captured an image.',
  }) : super(key: key);


  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  static const circularRadius = Radius.circular(16.0);
  BorderRadius handwritingBorderRadius = BorderRadius.only();
  BorderRadius cameraBorderRadius = BorderRadius.only();
  BorderRadius galleryBorderRadius = BorderRadius.only();

  late ThemeData theme;
  File? _image;
  final picker = ImagePicker();
  String _retrieveDataError = '';

  bool showCropper = false;

  @override
  void initState() {
    setBorderRadius();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          child: Platform.isAndroid
              ? FutureBuilder<void>(
            future: Services.retrieveLostData(
                picker,
                onLoaded: (file) {
                  setImage(file);
                },
                onError: (str) {
                  _retrieveDataError = str;
                }
            ),
            builder: (_, snapshot) {
              return _getFutureBuilderStates(snapshot);
            },
          )
              : ProfileImageView(
            image: _image,
            imageUrl: widget.url,
            retrieveDataError: _retrieveDataError,
          ),
        ),
        widget.editable ? Container(
          width: widget.width,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.label,
                style: theme.textTheme.bodyText2!.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  widget.cameraVisible
                      ?  getUserAction(
                    Icons.add_a_photo,
                    onTap: () => setImageByImageSource(
                      ImageSource.camera,
                    ),
                    borderRadius: cameraBorderRadius,
                  ) : Container(),
                  widget.galleryVisible
                      ? getUserAction(
                    Icons.attach_file,
                    onTap: () => setImageByImageSource(
                      ImageSource.gallery,
                    ),
                    borderRadius: galleryBorderRadius,
                    showDivider: false,
                  ): Container(),
                ],
              ),
            ],
          ),
        ) : SizedBox(),
      ],
    );
  }

  Widget getUserAction(
    IconData icon, {
    required VoidCallback onTap,
    required BorderRadius borderRadius,
    bool showDivider = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: borderRadius,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Icon(icon, color: theme.buttonColor),
          ),
        ),
        showDivider ? VerticalDivider(width: 1.0) : Container(),
      ],
    );
  }

  Widget _getFutureBuilderStates(AsyncSnapshot<void> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        return const CircularProgressIndicator();
      case ConnectionState.active:
        return const CircularProgressIndicator();
      case ConnectionState.waiting:
        return const CircularProgressIndicator();
      case ConnectionState.done:
        return ProfileImageView(
          image: _image,
          imageUrl: widget.url,
          retrieveDataError: _retrieveDataError,
        );
      default:
        if (snapshot.hasError) {
          return Text(
            'You have not yet picked/captured an image.',
            textAlign: TextAlign.center,
          );
        } else {
          return Text(
            'You have not yet picked/captured an image.',
            textAlign: TextAlign.center,
          );
        }
    }
  }


  Future<void> setImageByImageSource(ImageSource imageSource) async {
    bool isPermitted = await Services.checkPermission(
      imageSource,
      permissionError: (permission) {
        if (permission == Permission.camera) {
          widget.onErrorMessage!(widget.cameraPermissionErrorMessage);
          return;
        }

        widget.onErrorMessage!(widget.galleryPermissionErrorMessage);
        return;
      },
    );

    if (isPermitted) {
      final pickedFile = await picker.getImage(source: imageSource);
      if (pickedFile == null) {
        return;
      }

      Services.cropImage(
        File(pickedFile.path),
        onCrop: (croppedFile) {
          if (croppedFile == null) {
            widget.onErrorMessage!(widget.imageNotSelectedMessage);
          }

          setImage(croppedFile);
        },
      );
      return;
    }
  }

  void setImage(File? file) {
    widget.onFileSelection(file!);

    setState(() {
      _image = file;
    });
  }

  void setBorderRadius() {

    cameraBorderRadius = BorderRadius.horizontal(
      left:  circularRadius,
      right: widget.cameraVisible && !widget.galleryVisible
          ? circularRadius
          : Radius.zero,
    );

    galleryBorderRadius = BorderRadius.horizontal(
      left: widget.galleryVisible &&
          !(widget.cameraVisible)
          ? circularRadius
          : Radius.zero,
      right: circularRadius,
    );
  }
}
