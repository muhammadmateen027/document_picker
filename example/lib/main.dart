import 'dart:io';

import 'package:document_picker/document_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonColor: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Image picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 30),
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
            SizedBox(height: 40),

            DocumentSelector(
              url: '',
              editable: true,
              height: 90,
              iconsBackgroundColor: Colors.red,
              handwritingVisible: false,
              onFileSelection: (File? file) {
                print(file);
              },
              onErrorMessage: (message) {
                print(message);
              },
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
