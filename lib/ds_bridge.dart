import 'package:ds_bridge/ds_bridge_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:ds_bridge/ds_bridge_controller.dart';

typedef void DsBridgeWebViewCreatedCallback(DsBridgeController controller);

const CHANNEL_NAME = "shmy.tech.ds_bridge";

class DsBridgeWebView extends StatefulWidget {
  DsBridgeWebView({
    Key key,
    this.onTextViewCreated,
  }) : super(key: key);
  final DsBridgeWebViewCreatedCallback onTextViewCreated;

  @override
  _DsBridgeWebViewState createState() => _DsBridgeWebViewState();
}

class _DsBridgeWebViewState extends State<DsBridgeWebView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: CHANNEL_NAME,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onTextViewCreated == null) {
      return;
    }
    widget.onTextViewCreated(new DsBridgeController(id));
  }
}
