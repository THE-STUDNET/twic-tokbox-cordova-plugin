package com.thestudnet.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.squareup.otto.Subscribe;
import com.thestudnet.twicandroidplugin.events.EventBus;

/**
 * This class echoes a string called from JavaScript.
 */
public class TWICCordovaPlugin extends CordovaPlugin {

    private Context mContext;

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);
        // Register bus events
        EventBus.getInstance().register(this);
    }

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("launchHangout")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mContext = cordova.getActivity().getApplicationContext();
                    try {
                        // Launch native plugin
                        com.thestudnet.twicandroidplugin.TWICAndroidPlugin.getInstance().initContext(mContext).configure(args.getString(0)).launch();
                    } catch (JSONException e) {
                        callbackContext.error(e.getMessage());
                    }
                    // Call Cordova success callback
                    callbackContext.success();
                }
            });
            return true;
        }
        return false;
    }

    @Subscribe
    public void OnPluginInteraction(com.thestudnet.twicandroidplugin.events.PluginInteraction.OnPluginInteractionEvent event) {
        Log.d("TWICCordovaPlugin", "IN OnPluginInteraction");
        if(event.getType() == com.thestudnet.twicandroidplugin.events.PluginInteraction.Type.IS_INITIALIZED) {
            Intent intent = new Intent(mContext, com.thestudnet.twicandroidplugin.activities.TWICAndroidPluginActivity.class);
            cordova.getActivity().startActivity(intent);
        }
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);
        // Unregister bus events
        EventBus.getInstance().unregister(this);
    }

}
