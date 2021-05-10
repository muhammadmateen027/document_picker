import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

// ignore: must_be_immutable
class ImageSelector extends StatefulWidget {
  final bool cameraVisible, galleryVisible, handwritingVisible;
  final String imageAsset;
  final String url;
  final Function(File file) onFileSelection;
  final double height;
  final bool editable;
  final BoxShape shape;
  String cameraPermissionErrorMessage;
  String galleryPermissionErrorMessage;
  Function(String) onErrorMessage;
  String label;
  Color iconsBackgroundColor;
  Color iconColor;
  String imageNotSelectedMessage;

  ImageSelector({
    Key key,
    @required this.editable,
    @required this.url,
    @required this.onFileSelection,
    this.cameraVisible = true,
    this.galleryVisible = true,
    this.handwritingVisible = true,
    this.imageAsset = 'assets/images/card_sample.png',
    this.height = 170,
    this.shape = BoxShape.rectangle,
    this.onErrorMessage,
    this.label = 'Select an image',
    this.cameraPermissionErrorMessage =
        'Please allow camera permission from Settings',
    this.galleryPermissionErrorMessage =
        'Please allow gallery permission from Settings',
    this.imageNotSelectedMessage = 'You have not yet picked/captured an image.',
    this.iconsBackgroundColor = Colors.green,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  static const circularRadius = Radius.circular(16.0);

  String _retrieveDataError;
  File _image;
  bool showSignaturePad = false;
  SignatureController _signatureController;
  final picker = ImagePicker();

  final BoxConstraints constraints =  BoxConstraints(
    minHeight: 160,
    minWidth: 100,
  );

  BorderRadius handwritingBorderRadius = BorderRadius.only();
  BorderRadius cameraBorderRadius = BorderRadius.only();
  BorderRadius galleryBorderRadius = BorderRadius.only();

  @override
  void initState() {
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.green,
      exportBackgroundColor: Colors.white,
    );
    setBorderRadius();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _getImageContainer(widget.label);
  }

  Widget _getImageContainer(String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: Alignment.center,
      child: DottedBorder(
        color: Colors.grey,
        borderType: BorderType.RRect,
        radius: Radius.circular(
            widget.shape == BoxShape.circle ? widget.height : 12),
        padding: EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Container(
            height: widget.height,
            constraints: constraints,
            decoration: BoxDecoration(
              shape: widget.shape,
            ),
            child: widget.editable
                ? Stack(
                    children: <Widget>[
                      Center(
                        child: Platform.isAndroid
                            ? FutureBuilder<void>(
                                future: retrieveLostData(),
                                builder: (_, snapshot) {
                                  return _getFutureBuilderStates(snapshot);
                                },
                              )
                            : _getImageView(),
                      ),
                      !showSignaturePad
                          ? _imagePickers(title)
                          : _signaturePad(),
                    ],
                  )
                : Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: _getImageView(),
                  ),
          ),
        ),
      ),
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
        return _getImageView();
      default:
        if (snapshot.hasError) {
          return Text(
            widget.imageNotSelectedMessage,
            textAlign: TextAlign.center,
          );
        } else {
          return Text(
            widget.imageNotSelectedMessage,
            textAlign: TextAlign.center,
          );
        }
    }
  }

  Widget _signaturePad() {
    return Container(
      height: widget.height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: widget.shape,
      ),
      child: Column(
        children: <Widget>[
          Container(
            child: Signature(
              controller: _signatureController,
              width: double.infinity,
              height: 130,
              backgroundColor: Colors.white,
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showSignaturePad = false;
                    });
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.red,
                  ),
                ),
              ),
              Container(
                child: InkWell(
                  onTap: () {
                    if (_signatureController.isNotEmpty) {
                      _signatureController.clear();
                      return;
                    }
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.orange,
                  ),
                ),
              ),
              Container(
                child: InkWell(
                  onTap: () async {
                    if (_signatureController.isEmpty) {
                      setImage(null);
                      return;
                    }

                    Uint8List img = await _signatureController.toPngBytes();

                    int timestamp = new DateTime.now().millisecondsSinceEpoch;
                    final dir = await getTemporaryDirectory();

                    var file = File('${dir.absolute.path}/$timestamp.png');
                    file.writeAsBytesSync(img);

                    setImage(file);
                    setState(() {
                      showSignaturePad = false;
                    });
                    _signatureController.clear();
                  },
                  child: Icon(
                    Icons.done,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _imagePickers(String title) {
    return Container(
      alignment: Alignment.center,
      height: widget.height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: widget.shape,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.handwritingVisible
                  ? getUserAction(
                      Icons.gesture,
                      onTap: () {
                        setState(() {
                          showSignaturePad = true;
                        });
                      },
                      borderRadius: handwritingBorderRadius,
                    )
                  : Container(),
              widget.cameraVisible
                  ? getUserAction(
                      Icons.add_a_photo,
                      onTap: () => setImageByImageSource(
                        ImageSource.camera,
                        showErrorMessage: widget.onErrorMessage,
                      ),
                      borderRadius: cameraBorderRadius,
                    )
                  : Container(),
              widget.galleryVisible
                  ? getUserAction(
                      Icons.attach_file,
                      onTap: () => setImageByImageSource(
                        ImageSource.gallery,
                        showErrorMessage: widget.onErrorMessage,
                      ),
                      borderRadius: galleryBorderRadius,
                      showDivider: false,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget getUserAction(
    IconData icon, {
    @required Function onTap,
    @required BorderRadius borderRadius,
    bool showDivider = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: widget.iconsBackgroundColor,
              borderRadius: borderRadius,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: Icon(icon, color: widget.iconColor),
          ),
        ),
        showDivider ? VerticalDivider(width: 1.0) : Container(),
      ],
    );
  }

  Future<void> setImageByImageSource(ImageSource imageSource,
      {Function(String) showErrorMessage}) async {
    bool isPermitted = await checkPermission(
      imageSource,
      showErrorMessage: showErrorMessage,
    );

    if (isPermitted) {
      final pickedFile = await picker.getImage(source: imageSource);
      if (pickedFile == null) {
        return;
      }
      setImage(File(pickedFile.path));
      return;
    }
  }

  Future<bool> checkPermission(ImageSource imageSource,
      {Function(String) showErrorMessage}) async {
    PermissionStatus status;
    if (imageSource == ImageSource.camera) {
      status = await Permission.camera.status;
      if (status.isDenied ||
          status.isPermanentlyDenied ||
          status.isRestricted) {
        showErrorMessage(widget.cameraPermissionErrorMessage);
        return false;
      }
    }

    status = await Permission.photos.status;

    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      showErrorMessage(widget.galleryPermissionErrorMessage);
      return false;
    }

    if (status.isUndetermined) {
      if (imageSource == ImageSource.camera) {
        await Permission.camera.request();
        return true;
      }

      await Permission.photos.request();
      return true;
    }

    return true;
  }

  void setImage(File file) {
    widget.onFileSelection(file);

    setState(() {
      _image = file;
    });
  }

  Widget _getImageView() {
    Widget widgetView;
    final Text retrieveError = _retrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (_image == null) {
      if (widget.url?.isEmpty ?? true) {
        widgetView = Image.asset(widget.imageAsset, package: 'document_picker');
      } else {
        widgetView = Image.network(
          widget.url,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes
                    : null,
              ),
            );
          },
        );
      }
    } else {
      widgetView = Image.file(_image);
    }

    return widgetView;
  }

  Text _retrieveErrorWidget() {
    if (_retrieveDataError == null) {
      return null;
    }

    _retrieveDataError = null;
    return Text(_retrieveDataError);
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response == null || response.isEmpty) {
      return;
    }
    if (response.file == null) {
      _retrieveDataError = response.exception.code;

      return;
    }

    if (response.type == RetrieveType.video) {
      return;
    }

    setState(() {
      _image = File(response.file.path);
    });
  }

  void setBorderRadius() {
    handwritingBorderRadius = BorderRadius.horizontal(
      left: widget.handwritingVisible ? circularRadius : Radius.zero,
      right: widget.handwritingVisible &&
              !(widget.cameraVisible || widget.galleryVisible)
          ? circularRadius
          : Radius.zero,
    );

    cameraBorderRadius = BorderRadius.horizontal(
      left: widget.cameraVisible && !widget.handwritingVisible
          ? circularRadius
          : Radius.zero,
      right: widget.cameraVisible && !widget.galleryVisible
          ? circularRadius
          : Radius.zero,
    );

    galleryBorderRadius = BorderRadius.horizontal(
      left: widget.galleryVisible &&
              !(widget.handwritingVisible || widget.cameraVisible)
          ? circularRadius
          : Radius.zero,
      right: widget.galleryVisible ? circularRadius : Radius.zero,
    );
  }
}
