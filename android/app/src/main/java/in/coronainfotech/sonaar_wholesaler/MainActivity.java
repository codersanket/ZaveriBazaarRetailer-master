package in.coronainfotech.sonaar_retailer;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

//for disabling screenshot throughout the app
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        // for disabling screenshot throughout the app
        getWindow().addFlags(LayoutParams.FLAG_SECURE);
    }
}
