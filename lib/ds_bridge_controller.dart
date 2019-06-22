import 'dart:async';

import 'package:ds_bridge/ds_bridge_defs.dart';
import 'package:ds_bridge/ds_bridge_value.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class DsBridgeController extends ValueNotifier<DsBridgeValue> {
  MethodChannel _methodChannel;
  EventChannel _eventChannel;
  StreamSubscription _streamSubscription;

  DsBridgeController(int id) : super(DsBridgeValue()) {
    _methodChannel = new MethodChannel('$CHANNEL_NAME/method/$id');
    _eventChannel = new EventChannel('$CHANNEL_NAME/event/$id');
    _streamSubscription = _eventChannel.receiveBroadcastStream().listen((data) {
      value = value.copyWith(
        title: data["title"],
        url: data["url"],
        progress: data["progress"],
        canGoBack: data["canGoBack"],
      );
    });
  }

  void setUrl(String url) {
    _methodChannel.invokeMethod("setUrl", url);
  }

  void reload() {
    _methodChannel.invokeMethod("reload");
  }

  void cancel() {
    _methodChannel.invokeMethod("cancel");
  }

  void back() {
    _methodChannel.invokeMethod("back");
  }
  void dispose() {
    _streamSubscription?.cancel();
  }
}
