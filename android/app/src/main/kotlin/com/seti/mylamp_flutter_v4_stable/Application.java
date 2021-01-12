package com.seti.mylamp_flutter_v4_stable;

/**
 * Created by Gilang Arinata on 20/10/20.
 * https://github.com/gilangarinata/
 */
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    }
}