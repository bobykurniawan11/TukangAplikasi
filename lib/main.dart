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
  File pickedImage = null;
  var text = '';
  bool imageLoaded = false;
  List<Rect> rect = new List<Rect>();
  bool isFaceDetected = false;
  var imageFile;

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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              (pickedImage == null) ? Container() : Container(height: 200,width: 200, child: Image.file(pickedImage),),
              FlatButton(
                child: Text("Pilih Gambar"),
                onPressed: () {
                  setState(() {
                    imageLoaded = false;
                    pickedImage = null;
                  });
                  getImage();
                },
                color: Colors.greenAccent,
              ),
              (pickedImage != null)
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text("Baca teks"),
                    onPressed: () {
                      setState(() {
                        isFaceDetected = false;
                        TextrecognitionProcess();
                      });
                    },
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FlatButton(
                      child: Text("Deteksi Wajah"),
                      onPressed: () {
                        setState(() {
                          FacerecognitionProcess();
                        });
                      },
                      color: Colors.blue),
                ],
              )
                  : Container(),
              (!isFaceDetected)
                  ? Text(text)
                  : Center(
                child: Container(
                  height: 200,
                  width: 200,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: FittedBox(
                    child: SizedBox(
                      width: imageFile.width.toDouble(),
                      height: imageFile.height.toDouble(),
                      child: CustomPaint(
                        painter:
                        FacePainter(rect: rect, imageFile: imageFile),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  getImage() async {

    var awaitImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = awaitImage;
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

  FacerecognitionProcess() async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
    FaceDetector faceDetector = FirebaseVision.instance.faceDetector();

    imageFile = await pickedImage.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);

    //Proses
    final List<Face> faces = await faceDetector.processImage(visionImage);
    if (rect.length > 0) {
      rect = new List<Rect>();
    }
    for (Face face in faces) {
      rect.add(face.boundingBox);
    }

    setState(() {
      isFaceDetected = true;
    });
  }
}

class FacePainter extends CustomPainter {
  List<Rect> rect;
  var imageFile;

  FacePainter({@required this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    for (Rect rectangle in rect) {
      canvas.drawRect(
        rectangle,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}
