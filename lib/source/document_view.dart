import 'dart:io';

import 'package:flutter/material.dart';

class DocumentView extends StatelessWidget {
  final String retrieveDataError;
  final File? image;
  final String imageUrl;
  final String asset;

  const DocumentView({Key? key, required this.retrieveDataError, required this.image, required this.imageUrl, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widgetView;
    final Text? retrieveError = _retrieveErrorWidget();
    if (retrieveError != null) {

      return retrieveError;
    }

    if (image == null) {
      if (imageUrl.isNotEmpty) {
        widgetView = Image.network(
          imageUrl,
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      } else {
        widgetView = Image.asset(asset, package: 'document_picker');
      }
    } else {
      widgetView = Image.file(image!);
    }

    return widgetView;
  }

  Text? _retrieveErrorWidget() {
    if (retrieveDataError.isEmpty) {
      return null;
    }
    return Text(retrieveDataError);
  }
}