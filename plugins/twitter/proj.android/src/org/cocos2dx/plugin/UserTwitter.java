package org.cocos2dx.plugin;

import java.util.Hashtable;
import java.util.Iterator;
import java.util.ArrayList;
/*
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.FileNotFoundException;
*/
import java.io.*;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import twitter4j.*;
import twitter4j.auth.*;

public class UserTwitter implements InterfaceUser {

    private static final String LOG_TAG = "UserTwitter";
    private static Activity mContext = null;
    public static UserTwitter instance = null;
    protected static boolean bDebug = false;
    public static final String CONSUMER_KEY = "jjAGuCTPEhTwbdkGRBNUmw";
    public static final String CONSUMER_SECRET = "Ad5wMzwcbAbJGMy5NCj0T8QMAlssdXJcj6BPVWbMb1A";
    private static final String ACCESS_TOKEN_FILE_NAME = "twitter_access_token";
    private final Twitter _twttr;
    private AccessToken _accessToken;

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
        _twttr = new TwitterFactory().getInstance();
        _twttr.setOAuthConsumer(CONSUMER_KEY, CONSUMER_SECRET);
        try {
            ObjectInputStream in = new ObjectInputStream(context.openFileInput(ACCESS_TOKEN_FILE_NAME));
            _accessToken = (AccessToken)in.readObject();
            in.close();
            _twttr.setOAuthAccessToken(_accessToken);
        } catch (FileNotFoundException e) {
        } catch (Exception e) {
            e.printStackTrace();
        }
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
        if (isLogined()) {
            UserWrapper.onActionResult(this, UserWrapper.ACTION_RET_LOGIN_SUCCEED, _accessToken.getScreenName());
        } else {
            Intent intent = new Intent(mContext, TwitterAuthActivity.class);
            mContext.startActivity(intent);
        }
    }

    public void onLoginSuccess(AccessToken token) {
        _accessToken = token;
        _twttr.setOAuthAccessToken(token);
        try {
            ObjectOutputStream out = new ObjectOutputStream(mContext.openFileOutput(ACCESS_TOKEN_FILE_NAME, Context.MODE_PRIVATE));
            out.writeObject(token);
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        UserWrapper.onActionResult(this, UserWrapper.ACTION_RET_LOGIN_SUCCEED, token.getScreenName());
    }

    public void onLoginCancel() {
        UserWrapper.onActionResult(this, UserWrapper.ACTION_RET_LOGIN_FAILED, "cancel");
    }

    public String api(org.json.JSONObject params) {
        try {
            String path = params.getString("Param1");
            String method = params.getString("Param2");
            org.json.JSONObject param = params.getJSONObject("Param3");
            Iterator<String> it = param.keys();
            ArrayList<String> keys = new ArrayList<String>();
            while (it.hasNext()) {
                String key = it.next();
                keys.add(key);
            }
            twitter4j.conf.Configuration conf = _twttr.getConfiguration();
            HttpClient http = HttpClientFactory.getInstance(conf.getHttpClientConfiguration());
            HttpParameter[] httpParams = new HttpParameter[keys.size()];
            for (int i = 0; i < keys.size(); i++) {
                String key = keys.get(i);
                String value = param.getString(key);
                httpParams[i] = new HttpParameter(key, value);
            }
            Authorization auth = _twttr.getAuthorization();
            return http.get(conf.getRestBaseURL() + path + ".json", httpParams, auth, null).asString();
        } catch (org.json.JSONException e) {
            e.printStackTrace();
        } catch (TwitterException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "{\"errors\":[{\"message\":\"invalid params\",\"code\":999}]}";
    }

    @Override
    public void logout() {}

    @Override
    public boolean isLogined() { return _accessToken != null; }

    @Override
    public String getSessionID() { return _accessToken.getUserId() + ""; }

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
