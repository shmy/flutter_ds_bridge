import 'dart:async';
import 'dart:convert';
import 'package:ds_bridge/ds_bridge_defs.dart';
import 'package:ds_bridge/ds_bridge_value.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DsBridgeController extends ValueNotifier<DsBridgeValue> {
  MethodChannel _methodChannel;
  EventChannel _eventChannel;
  StreamSubscription _streamSubscription;
  Function onJSCall;
  DsBridgeController(int id) : super(DsBridgeValue()) {
    _methodChannel = new MethodChannel('$CHANNEL_NAME/method/$id');
    _eventChannel = new EventChannel('$CHANNEL_NAME/event/$id');
    _streamSubscription = _eventChannel.receiveBroadcastStream().listen((data) {
      var progress = (data["progress"]).toDouble();
      value = value.copyWith(
        title: data["title"],
        url: data["url"],
        progress: progress,
        canGoBack: data["canGoBack"],
      );
    });
    _methodChannel.setMethodCallHandler((MethodCall call) {
      if (call.method == "callFlutter") {
        try {
          Map<String, dynamic> body = json.decode(call.arguments);
          if (onJSCall != null) {
            return Future.value(onJSCall(body));
          }
          return Future.value(null);
        } catch (e) {
          return Future.value(e);
        }

      }

      return Future.value(null);
    });
  }
  void setOnJSCall(Function onJSCall) {
    this.onJSCall = onJSCall;
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
    _methodChannel?.setMethodCallHandler(null);
  }
}
