package com.timetable.stella.statusbarinset;

import android.view.View;

import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;

/**
 * Exposes the real on-device status bar inset (top, in dp) to JS via WindowInsetsCompat —
 * the same API cordova-android itself uses internally (CordovaActivity#createViews) to size
 * the gray status bar backdrop view. Reading it the same way guarantees the value matches
 * exactly what's drawn on screen, regardless of device/notch/cutout differences.
 *
 * JS side: cordova.plugins.statusBarInset.getInsetTopDp(successCb, errorCb)
 *   successCb(dp: number)
 *   errorCb(reason: string) — e.g. "insets_not_ready" if called before the window has
 *   completed its first layout pass; callers should retry or fall back to a fixed constant.
 */
public class StatusBarInsetPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) {
        if (!"getInsetTopDp".equals(action)) {
            return false;
        }

        cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    View decorView = cordova.getActivity().getWindow().getDecorView();
                    WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(decorView);
                    if (insets == null) {
                        callbackContext.error("insets_not_ready");
                        return;
                    }
                    int topPx = insets.getInsets(WindowInsetsCompat.Type.statusBars()).top;
                    float density = cordova.getActivity().getResources().getDisplayMetrics().density;
                    int topDp = Math.round(topPx / density);
                    callbackContext.success(topDp);
                } catch (Exception e) {
                    callbackContext.error(String.valueOf(e));
                }
            }
        });

        return true;
    }
}
