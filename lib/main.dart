import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;

void main() => runApp(new CameraApp());

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  File imageInsert;

  Future getImage(bool isCamera) async {
    File imageCamera;
    if(isCamera){
      imageCamera = await ImagePicker.pickImage(source: ImageSource.camera);
    }else{
      imageCamera = await ImagePicker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      imageInsert = imageCamera;
    });

  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Image Picker'),
          backgroundColor: Colors.purple,
        ),
        body: new Container(
          child: new Center(
            child: imageInsert == null
                ? new Text('No Image to Show ')
                : new Image.file(imageInsert),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.album),
                color: Colors.white,
                onPressed: () {
                  getImage(false);
                },
              ),
              IconButton(
                icon: Icon(Icons.save),
                color: Colors.white,
                onPressed: () {
//                  _saveImage();

                  _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Image Saved'),
                        duration: Duration(seconds: 3),
                      ));
                },
              ),
            ],
          ),
          color: Colors.blueGrey,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
          ),
          onPressed: (){
            getImage(true);
          },
        ),
      ),
    );
  }

//   _saveImage() async{
//    RenderRepaintBoundary boundary =
//    _scaffoldKey.currentContext.findRenderObject();
//    ui.Image image = await boundary.toImage();
//    ByteData byteData =
//        await image.toByteData(format: ui.ImageByteFormat.png);
//    final result = await ImageGallerySaver.save(byteData.buffer.asUint8List());
//    print(result);
//  }
}
