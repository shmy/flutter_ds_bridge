//
// Created by 王超 on 2019-06-25.
//

import Foundation
import Flutter

public class JsApi {
    var methodChannel: FlutterMethodChannel
    public init(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
    }
    private func callFlutterAsyn(message: String, completionHandler: JSCallback) {
        self.methodChannel.invokeMethod("callFlutter", arguments: message)
        completionHandler("ok", true)
    }
}