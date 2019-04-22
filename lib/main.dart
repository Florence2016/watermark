import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';
import 'package:watermark_editor/bottom_fab_bar/fab_bottom_app_bar.dart';

void main() => runApp(new CameraApp());

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _globalScaffoldKey =  GlobalKey<ScaffoldState>();
  GlobalKey _imageSavedKey = GlobalKey();
  File imageInsert;
  File imageCamera;
  final myInputText = TextEditingController();
  Future getImage(bool isCamera) async {

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
  void initState() {
    super.initState();
    PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage, // Here add the required permissions

    ]);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myInputText.dispose();
    super.dispose();
  }

  String _lastSelected = 'TAB: 0';

  void _selectedBMenuTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      print(index);
      //0 is gallery, 1 is text, 2 is watermark, 3 is save
      if(index == 0){
        getImage(false);
      }
      if(index == 3){
        _saveImage();
        _globalScaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Image Saved'),
              duration: Duration(seconds: 3),
            ));
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _globalScaffoldKey,
        appBar: new AppBar(
          title: new Text('Image Picker'),
          backgroundColor: Colors.purple,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RepaintBoundary(
                key: _imageSavedKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: imageInsert == null
                          ? new Text('No Image to Show ')
                          : new Image.file(imageInsert),
                    ),
                    Text(myInputText.text),
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: FABBottomAppBar(
          color: Colors.grey,
          selectedColor: Colors.red,
          notchedShape: CircularNotchedRectangle(),
          onTabSelected: _selectedBMenuTab,
            items: [
              FABBottomAppBarItem(iconData: Icons.album, text: 'Gallery',),
              FABBottomAppBarItem(iconData: Icons.text_fields, text: 'Text'),
              FABBottomAppBarItem(iconData: Icons.ac_unit, text: 'Watermark'),
              FABBottomAppBarItem(iconData: Icons.save, text: 'Save'),
            ],
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

   _saveImage() async{
    RenderRepaintBoundary boundary =
    _imageSavedKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final result = await ImageGallerySaver.save(byteData.buffer.asUint8List());
    print(result);
  }
}
