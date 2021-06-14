import 'dart:io';

import 'package:flutter/material.dart';

class ProfileImageView extends StatelessWidget {
  final String retrieveDataError;
  final File? image;
  final String imageUrl;

  const ProfileImageView({
    Key? key,
    required this.retrieveDataError,
    required this.image,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Widget widgetView;
    final Text? retrieveError = _retrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (image == null) {
      if (imageUrl.isNotEmpty) {
        widgetView = Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.disabledColor),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 140,
              height: 140,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.disabledColor),
              ),
            ),
          ],
        );
      } else {
        widgetView = Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.disabledColor),
            image: DecorationImage(
              image: ExactAssetImage('assets/images/person.png', package: 'document_picker'),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    } else {
      widgetView = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.disabledColor),
          image: DecorationImage(
            image: FileImage(image!),
            fit: BoxFit.cover,
          ),
        ),
      );
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
