package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import twitter4j.auth.*;

public class UserTwitter implements InterfaceUser {

    private static final String LOG_TAG = "UserTwitter";
    private static Activity mContext = null;
    public static UserTwitter instance = null;
    protected static boolean bDebug = false;
    public static final String CONSUMER_KEY = "jjAGuCTPEhTwbdkGRBNUmw";
    public static final String CONSUMER_SECRET = "Ad5wMzwcbAbJGMy5NCj0T8QMAlssdXJcj6BPVWbMb1A";

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
        instance = this;
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
        Intent intent = new Intent(mContext, TwitterAuthActivity.class);
        mContext.startActivity(intent);
    }

    public void onLoginSuccess(AccessToken token) {
        LogD("onLoginSuccess");
        LogD(token.toString());
    }

    public void onLoginCancel() {
        LogD("onLoginCancel");
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
