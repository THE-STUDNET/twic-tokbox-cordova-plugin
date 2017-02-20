package com.thestudnet.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.widget.Toast;
import android.content.Context;
import android.content.Intent;

/**
 * This class echoes a string called from JavaScript.
 */
public class TWICCordovaPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("configure")) {
            String message = args.getString(0);
            this.configure(message, callbackContext);
            return true;
        }
        else if (action.equals("show")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Context context = cordova.getActivity().getApplicationContext();
                    Intent intent = new Intent(context, com.thestudnet.twicandroidplugin.activities.VideoGridActivity.class);
                    cordova.getActivity().startActivity(intent);
                }
            });
            return true;
        }
        return false;
    }

    private void configure(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            Toast.makeText(webView.getContext(), "jai reçu ce param : " + message, Toast.LENGTH_LONG).show();
            callbackContext.success("native code executed");
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }
}
