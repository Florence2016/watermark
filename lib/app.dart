import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';
import 'package:watermark_editor/bottom_fab_bar/fab_bottom_app_bar.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _globalScaffoldKey =  GlobalKey<ScaffoldState>();
  GlobalKey _imageSavedKey = GlobalKey();

  File imageInsert, imageCamera,insertWatermark, imageWatermark;

  TextEditingController myInputText = TextEditingController();

  Offset offset = Offset.zero;
  Offset offset1 = Offset.zero;

  String _lastSelected = 'TAB: 0';

  @override
  void initState() {
    super.initState();

    handleAppLifecycleState();
    PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage, // Here add the required permissions
      PermissionGroup.camera
    ]);
  }

  handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    SystemChannels.lifecycle.setMessageHandler((msg) {

      print('SystemChannels> $msg');

      switch (msg) {
        case "AppLifecycleState.paused":
          _lastLifecyleState = AppLifecycleState.paused;
          break;
        case "AppLifecycleState.inactive":
          _lastLifecyleState = AppLifecycleState.inactive;
          break;
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          break;
        case "AppLifecycleState.suspending":
          _lastLifecyleState = AppLifecycleState.suspending;
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myInputText.dispose();
    getWatermark();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: _globalScaffoldKey,
      appBar: new AppBar(
        title: new Text('Image Picker'),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
            child: Column(
              children: <Widget>[
                RepaintBoundary(
                  key: _imageSavedKey,
                  child: Stack(
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 100/100,
                        child: Container(
                          alignment: Alignment.center,
                          child: imageInsert == null
                              ? new Text('No Image to Show ')
                              : new Image.file(imageInsert),

                        ),
                      ),
                          Positioned(
                            left: offset.dx,
                            top: offset.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  offset = Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                                });
                              },
                              child: Text(myInputText.text,
                              style: TextStyle(
                                fontSize: 20.0
                              ),),
                            ),
                          ),
                      Positioned(
                        left: offset1.dx,
                        top: offset1.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              offset1 = Offset(offset1.dx + details.delta.dx, offset1.dy + details.delta.dy, );
                            });
                          },
                          child: Container(
                            width: 100, height: 100,
                            child: insertWatermark == null ? null : Image.file(insertWatermark) ,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
          ]
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
      floatingActionButton: SafeArea(
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                FloatingActionButton(
                  backgroundColor: Colors.purple,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: (){
                    getImage(true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _displayDialog(BuildContext context) async {
    TextEditingController value = new TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Input a Text'),
            content: TextField(
              controller: value,
              decoration: InputDecoration(hintText: "Text"),
            ),
            actions: <Widget>[
               FlatButton(
                 textColor: Colors.purple,
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
               RaisedButton(
                 color: Colors.purple,
                 textColor: Colors.white,
                 child: Text('Confirm'),
                 onPressed: () {
                   Navigator.of(context).pop();
                   setState(() {
                     myInputText = value;
                   });
                 },
               ),
            ],
          );
        });
  }

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
  Future getWatermark() async {
    imageWatermark = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      insertWatermark = imageWatermark;
    });
  }

  void _selectedBMenuTab(int index) {
    setState(() {
      _lastSelected = 'TAB: $index';
      print(index);
      //0 is gallery, 1 is text, 2 is watermark, 3 is save
      if(index == 0){
        getImage(false);
      }
      if(index == 1){
        _displayDialog(context);
      }
      if (index == 2){
       getWatermark();
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
  _saveImage() async{
    RenderRepaintBoundary boundary =
    _imageSavedKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final result = await ImageGallerySaver.save(byteData.buffer.asUint8List());
    print(result);
  }
}
