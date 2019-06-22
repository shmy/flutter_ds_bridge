package tech.shmy.ds_bridge;

import android.support.annotation.Nullable;
import android.webkit.JavascriptInterface;

import io.flutter.plugin.common.MethodChannel;
import wendu.dsbridge.CompletionHandler;

public class JsApi {
    final MethodChannel methodChannel;

    JsApi(MethodChannel methodChannel) {
        this.methodChannel = methodChannel;
    }

    @JavascriptInterface
    public void callFlutterAsyn(Object args, CompletionHandler<Object> _handler) {
        final CompletionHandler<Object> handler = _handler;
        methodChannel.invokeMethod("callFlutter", args.toString(), new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object o) {
                handler.complete(o);
            }

            @Override
            public void error(String s, @Nullable String s1, @Nullable Object o) {
                handler.complete(null);
            }

            @Override
            public void notImplemented() {
                handler.complete(null);
                System.out.println("flutter 端 未实现");
            }
        });
    }
}