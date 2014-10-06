package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

public class UserTwitter implements InterfaceUser {

    private static final String LOG_TAG = "UserTwitter";
    private static Activity mContext = null;
    private static InterfaceUser mAdapter = null;
    protected static boolean bDebug = false;

    protected static void LogE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public UserTwitter(Context context) {
        mContext = (Activity) context;
        mAdapter = this;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
        LogD("initDeveloperInfo invoked " + cpInfo.toString());
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            }
        });
    }

    @Override
    public void login() {
        LogD("login");
    }

    @Override
    public void logout() {}

    @Override
    public boolean isLogined() { return false; }

    @Override
    public String getSessionID() { return ""; }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "4.0.2";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }

    private boolean networkReachable() {
        boolean bRet = false;
        try {
            ConnectivityManager conn = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo netInfo = conn.getActiveNetworkInfo();
            bRet = (null == netInfo) ? false : netInfo.isAvailable();
        } catch (Exception e) {
            LogE("Fail to check network status", e);
        }
        LogD("NetWork reachable : " + bRet);
        return bRet;
    }

}
