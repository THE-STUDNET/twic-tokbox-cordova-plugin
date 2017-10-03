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

import com.thestudnet.twicandroidplugin.events.EventBus;

/**
 * This class echoes a string called from JavaScript.
 */
public class TWICCordovaPlugin extends CordovaPlugin {

    private Context mContext;

    @Override
        public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
            if (action.equals("launchHangout")) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mContext = cordova.getActivity().getApplicationContext();
                        com.thestudnet.twicandroidplugin.TWICAndroidPlugin.getInstance().initContext(mContext).configure(args.getString(0)).launch();
                        callbackContext.success();
                    }
                });
                return true;
            }
            return false;
        }

    @Subscribe
        public void OnPluginInteraction(com.thestudnet.twicandroidplugin.events.PluginInteraction.OnPluginInteractionEvent event) {
            if(event.getType() == com.thestudnet.twicandroidplugin.events.PluginInteraction.Type.IS_INITIALIZED) {
                Log.d("TWICCordovaPlugin", "IS_INITIALIZED");
                Intent intent = new Intent(mContext, com.thestudnet.twicandroidplugin.activities.TWICAndroidPluginActivity.class);
                this.startActivity(intent);
            }
        }
}
