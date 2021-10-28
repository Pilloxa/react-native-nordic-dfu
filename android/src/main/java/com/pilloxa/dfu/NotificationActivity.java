package com.pilloxa.dfu;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ReactContext;

/**
 * Created by viktor on 2017-06-26.
 */

public class NotificationActivity extends Activity {

    private ReactInstanceManager reactInstanceManager;

    private ReactContext getReactContext() {
        reactInstanceManager = ((ReactApplication) getApplication())
                .getReactNativeHost()
                .getReactInstanceManager();
        return reactInstanceManager.getCurrentReactContext();
    }

    public Class getMainActivityClass(ReactContext reactContext) {
        String packageName = reactContext.getPackageName();
        Intent launchIntent = reactContext.getPackageManager().getLaunchIntentForPackage(packageName);
        String className = launchIntent.getComponent().getClassName();
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // If this activity is the root activity of the task, the app is not running
        if (isTaskRoot()) {
            ReactContext reactContext = getReactContext();
            Class HostActivity = getMainActivityClass(reactContext);
            // Start the app before finishing
            final Intent intent = new Intent(this, HostActivity);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtras(getIntent().getExtras()); // copy all extras
            startActivity(intent);
        }

        // Now finish, which will drop you to the activity at which you were at the top of the task stack
        finish();
    }
}
