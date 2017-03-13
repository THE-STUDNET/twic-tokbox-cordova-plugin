package com.thestudnet.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.widget.Toast;
import android.content.Context;
import android.content.Intent;

import java.text.SimpleDateFormat;
import java.util.Date;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

/**
 * This class echoes a string called from JavaScript.
 */
public class TWICCordovaPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("launchHangout")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    // Configure plugin
                    com.thestudnet.twicandroidplugin.TWICAndroidPlugin twicAndroidPlugin = com.thestudnet.twicandroidplugin.TWICAndroidPlugin.getInstance();

                    // Just a simple Firebase test
                    FirebaseDatabase firebaseDatabase = twicAndroidPlugin.getFirebaseDatabase();
                    DatabaseReference myRef = firebaseDatabase.getReference("message");
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
                    String currentDateandTime = sdf.format(new Date());
                    myRef.setValue("Hello, World! " + currentDateandTime);

                    // Launch activity
                    Context context = cordova.getActivity().getApplicationContext();
                    Intent intent = new Intent(context, com.thestudnet.twicandroidplugin.activities.VideoGridActivity.class);
                    cordova.getActivity().startActivity(intent);
                }
            });
            return true;
        }
        return false;
    }
}
