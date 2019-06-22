package tech.shmy.ds_bridge;

import android.content.Context;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;

class FlutterPlatformViewFactory extends io.flutter.plugin.platform.PlatformViewFactory {
    private final PluginRegistry.Registrar registrar;

    public FlutterPlatformViewFactory(PluginRegistry.Registrar registrar) {
        super(StandardMessageCodec.INSTANCE);
        this.registrar = registrar;
    }

    @Override
    public PlatformView create(Context context, int id, Object args) {
        return new DsBridgeWebView(context, registrar, args, id);
    }
}

