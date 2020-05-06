import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: 'Login dan Daftar dengan Firebase'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  File pickedImage;
  var text = '';
  bool imageLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (pickedImage == null) ? Container() : Image.file(pickedImage),
            FlatButton(
              child: Text("Pilih Gambar"),
              onPressed: () {
                getImage();
              },
              color: Colors.greenAccent,
            ),
            Text(text)
          ],
        ),
      ),
    );
  }

  getImage() async {
    var awaitImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = awaitImage;
      TextrecognitionProcess();
      imageLoaded = true;
    });
  }

  TextrecognitionProcess() async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    //Proses
    await textRecognizer.processImage(visionImage).then((result) {
      for (TextBlock block in result.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement word in line.elements) {
            setState(() {
              text = text + word.text + ' ';
            });
          }
          text = text + '\n';
        }
      }
      return result;
    }).catchError((err) {
      print(err.toString());
    });
    textRecognizer.close();
  }
}
