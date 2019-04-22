import 'package:flutter/material.dart';

class FabWithIcons extends StatefulWidget {
  FabWithIcons({ this.onIconTapped});
  ValueChanged<int> onIconTapped;
  @override
  State createState() => FabWithIconsState();
}

class FabWithIconsState extends State<FabWithIcons> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        _buildFab(),
          ]
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: Colors.purple,
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      tooltip: 'Increment',
      child: Icon(Icons.camera_alt),
      elevation: 2.0,
    );
  }
}