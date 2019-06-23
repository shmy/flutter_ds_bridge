package tech.shmy.ds_bridge;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.platform.PlatformView;
import wendu.dsbridge.DWebView;

import static tech.shmy.ds_bridge.DsBridgePlugin.CHANNEL_NAME;

public class DsBridgeWebView implements PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private DWebView dWebView;
    private Context context;
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    //WebChromeClient主要辅助WebView处理Javascript的对话框、网站图标、网站title、加载进度等
    private WebChromeClient webChromeClient = new WebChromeClient() {
        //DSBridge已经实现了 Javascript的弹出框函数(alert/confirm/prompt)
        //获取网页标题
        @Override
        public void onReceivedTitle(WebView view, String title) {
            sendState();
            super.onReceivedTitle(view, title);
        }

        //加载进度回调
        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            sendState();
            super.onProgressChanged(view, newProgress);
        }
    };

    //WebViewClient主要帮助WebView处理各种通知、请求事件
    private WebViewClient webViewClient = new WebViewClient() {
        @Override
        public void onPageFinished(WebView view, String url) {//页面加载完成
            sendState();
            super.onPageFinished(view, url);
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {//页面开始加载
            sendState();
            super.onPageStarted(view, url, favicon);
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            // 支持tel://协议
            if (url.startsWith("tel:")) {
                Intent intent = new Intent(Intent.ACTION_VIEW,
                        Uri.parse(url));
                context.startActivity(intent);
                return true;
            }

            return super.shouldOverrideUrlLoading(view, url);
        }

    };

    private DWebView.JavascriptCloseWindowListener javascriptCloseWindowListener = new DWebView.JavascriptCloseWindowListener() {
        @Override
        public boolean onClose() {
            //如果返回false,则阻止DWebView默认处理.
            return false;
        }
    };

    @SuppressLint({"SetJavaScriptEnabled", "ClickableViewAccessibility"})
    DsBridgeWebView(Context context, PluginRegistry.Registrar registrar, Object args, int id) {
        this.context = context;
        methodChannel = new MethodChannel(registrar.messenger(), CHANNEL_NAME + "/method/" + id);
        eventChannel = new EventChannel(registrar.messenger(), CHANNEL_NAME + "/event/" + id);
        methodChannel.setMethodCallHandler(this);
        eventChannel.setStreamHandler(this);
        dWebView = new DWebView(registrar.context());
        DWebView.setWebContentsDebuggingEnabled(false);
        dWebView.getSettings().setJavaScriptEnabled(true);
        dWebView.getSettings().setSavePassword(true);
        dWebView.getSettings().setSaveFormData(true);
        dWebView.getSettings().setSupportZoom(true);
        dWebView.setJavascriptCloseWindowListener(javascriptCloseWindowListener);
        dWebView.addJavascriptObject(new JsApi(methodChannel), "flutter");
        dWebView.setWebChromeClient(webChromeClient);
        dWebView.setWebViewClient(webViewClient);
        dWebView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                System.out.println("123");
                switch (motionEvent.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                    case MotionEvent.ACTION_UP:
                        if (!view.hasFocus()) {
                            view.requestFocus();
                        }
                        break;
                }

                return false;
            }
        });
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
        this.eventSink = null;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "setUrl":
                setUrl(methodCall, result);
                break;
            case "reload":
                reload(methodCall, result);
                break;
            case "cancel":
                cancel(methodCall, result);
                break;
            case "back":
                back(methodCall, result);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public View getView() {
        return dWebView;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        dWebView.destroy();
    }


    private void setUrl(MethodCall methodCall, MethodChannel.Result result) {
        dWebView.loadUrl((String) methodCall.arguments);
        result.success(null);
    }

    private void reload(MethodCall methodCall, MethodChannel.Result result) {
        dWebView.reload();
        result.success(null);
    }

    private void cancel(MethodCall methodCall, MethodChannel.Result result) {
        dWebView.stopLoading();
        result.success(null);
    }

    private void back(MethodCall methodCall, MethodChannel.Result result) {
        dWebView.goBack();
        result.success(null);
    }

    private void sendState() {
        if (eventSink == null) return;
        HashMap<String, Object> m = new HashMap<>();
        m.put("title", dWebView.getTitle());
        m.put("url", dWebView.getUrl());
        m.put("progress", dWebView.getProgress());
        m.put("canGoBack", dWebView.canGoBack());
        eventSink.success(m);
    }

}
