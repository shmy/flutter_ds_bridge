package tech.shmy.ds_bridge;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * DsBridgePlugin
 */
public class DsBridgePlugin {
    public static String CHANNEL_NAME = "shmy.tech.ds_bridge";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        registrar.platformViewRegistry().registerViewFactory(CHANNEL_NAME, new FlutterPlatformViewFactory(registrar));
    }
}
