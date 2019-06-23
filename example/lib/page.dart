import 'package:flutter/material.dart';
import 'package:ds_bridge/ds_bridge.dart';

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  DsBridgeController controller;

  double get _progress => (this.controller?.value?.progress ?? 0) / 100;

  String get _title => this.controller?.value?.title ?? "";

  bool get _isFinished => _progress == 1;

  bool get _canGoBack => this.controller?.value?.canGoBack ?? true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        title: Row(
          children: <Widget>[
            _buildIconButton(
              onTap: () {
                Navigator.of(context).pop();
              },
              icon: Icons.close,
            ),
            _canGoBack
                ? _buildIconButton(
                    onTap: () {
                      controller.back();
                    },
                    icon: Icons.arrow_back,
                  )
                : Container(),
            Expanded(
              child: Text(_title),
            ),
            _buildIconButton(
              onTap: _toolTaped,
              icon: _isFinished ? Icons.refresh : Icons.cancel,
            )
          ],
        ),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DsBridgeWebView(
              onTextViewCreated: (controller) {
                this.controller = controller;
                this.controller.setUrl("http://192.168.0.7:3001/dd_app/feedback");
                this.controller.addListener(() {
                  setState(() {});
                });
              },
            ),
          ),
          Positioned(
              left: 0.0,
              right: 0.0,
              top: 0.0,
              child: Offstage(
                offstage: _isFinished,
                child: LinearProgressIndicator(
                  value: _progress,
//              valueColor: ,
                ),
              )),
        ],
      ),
    );
  }

  void _toolTaped() {
    if (_isFinished) {
      controller.reload();
    } else {
      controller.cancel();
    }
  }

  Widget _buildIconButton({IconData icon, Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 5.0,
          right: 5.0,
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
