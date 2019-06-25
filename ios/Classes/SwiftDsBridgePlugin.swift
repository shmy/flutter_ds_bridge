import Flutter
import UIKit

let CHANNEL_NAME = "shmy.tech.ds_bridge";

public class SwiftDsBridgePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messager = registrar.messenger() as! (NSObject & FlutterBinaryMessenger)
        registrar.register(DsFlutterPlatformViewFactory(messenger: messager), withId: CHANNEL_NAME)
    }
}


public class DsFlutterPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    var messenger: FlutterBinaryMessenger!

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return DWebViewController(withFrame: frame, viewIdentifier: viewId, arguments: args, binaryMessenger: messenger)
    }

    @objc public init(messenger: (NSObject & FlutterBinaryMessenger)?) {
        super.init()
        self.messenger = messenger
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class DWebViewController: NSObject, FlutterPlatformView, FlutterStreamHandler {

    var viewId: Int64!;
    var eventSink: FlutterEventSink!;
    var _webView: DWKWebView!
    var methodChannel: FlutterMethodChannel!
    var eventChannel: FlutterEventChannel!

    public init(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        super.init()
        self.methodChannel = FlutterMethodChannel(name: "\(CHANNEL_NAME)/method/\(viewId)", binaryMessenger: binaryMessenger);
        self.methodChannel.setMethodCallHandler({
            [weak self]
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if let this = self {
                this.onMethodCall(call: call, result: result)
            }
        })
        self.eventChannel = FlutterEventChannel(name: "\(CHANNEL_NAME)/event/\(viewId)", binaryMessenger: binaryMessenger)
        self.eventChannel.setStreamHandler(self)
        self._webView = DWKWebView(frame: frame);
        self._webView.setJavascriptCloseWindowListener({
            return false;
        })
        self._webView.addObserver(self, forKeyPath: "title", options: NSKeyValueObservingOptions.new, context: nil)
        self._webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        let api = JsApi.init(methodChannel: self.methodChannel)
        self._webView.addJavascriptObject(api, namespace: "flutter")

    }

    public func view() -> UIView {
        return self._webView
    }

    public func dispose() {
        self.methodChannel.setMethodCallHandler(nil)
        self.eventChannel.setStreamHandler(nil)
    }
    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        let method = call.method
        switch (method) {
        case "setUrl":
            self.setUrl(call: call, result: result)
        case "reload":
            self.reload(call: call, result: result)
            break;
        case "cancel":
            self.cancel(call: call, result: result)
            break;
        case "back":
            self.back(call: call, result: result)
            break;
        default:
            result(FlutterMethodNotImplemented);
        }
    }

    // 设置 url
    private func setUrl(call: FlutterMethodCall, result: FlutterResult) {
        let url = call.arguments as! String
        var req: URLRequest! = URLRequest(url: URL(string: url)!)
        req.timeoutInterval = 20
        self._webView.load(req)
        result(nil)
    }

    // 刷新
    private func reload(call: FlutterMethodCall, result: FlutterResult) {
        self._webView.reload()
        result(nil)
    }

    // 取消
    private func cancel(call: FlutterMethodCall, result: FlutterResult) {
        self._webView.stopLoading()
        result(nil)
    }

    // 返回
    private func back(call: FlutterMethodCall, result: FlutterResult) {
        self._webView.goBack()
        result(nil)
    }

    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink;
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        self.sendState();
    }

    private func sendState() {
        if (self.eventSink != nil) {
            var m: Dictionary<String, Any> = Dictionary()
            m["title"] = self._webView.title
            m["url"] = try! String(contentsOf: self._webView.url!)
            m["progress"] = self._webView.estimatedProgress * 100
            m["canGoBack"] = self._webView.canGoBack
            eventSink(m)
        }
    }
}
