package org.cocos2dx.plugin;

import java.io.IOException;

import java.util.Hashtable;
import java.util.HashMap;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

import org.json.JSONObject;
import org.json.JSONArray;

import org.apache.http.HttpStatus;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.text.TextUtils;

import com.parse.Parse;
import com.parse.ParseUser;
import com.parse.ParseTwitterUtils;
import com.parse.ParseException;
import com.parse.LogInCallback;
import com.parse.ParseQuery;
import com.parse.CountCallback;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseCloud;
import com.parse.FunctionCallback;

public class UserParse implements InterfaceUser {

    private static final String LOG_TAG = "UserParse";
    private static Activity mActivity = null;
    private static boolean bDebug = false;

    protected static void LogE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public UserParse(Context context) {
        mActivity = (Activity)context;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        String appId = devInfo.get("ApplicationID");
        String clientKey = devInfo.get("ClientKey");
        String consumerKeyTw = devInfo.get("TwitterConsumerKey");
        String consumerSecretTw = devInfo.get("TwitterConsumerSecret");
        Parse.initialize(mActivity, appId, clientKey);
        ParseTwitterUtils.initialize(consumerKeyTw, consumerSecretTw);
    }

    @Override
    public void login() {
    }

    public void loginWithTwitter() {
        final InterfaceUser that = this;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ParseTwitterUtils.logIn(mActivity, new LogInCallback() {
                    public void done(ParseUser user, ParseException e) {
                        if (e == null && user != null) {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_SUCCEED, user.getUsername());
                        } else if (user == null) {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "cancel");
                        } else {
                            String msg;
                            switch(e.getCode()) {
                                case ParseException.CONNECTION_FAILED:
                                    msg = "network";
                                    break;
                                case ParseException.EXCEEDED_QUOTA:
                                    msg = "overquota";
                                    break;
                                case ParseException.INTERNAL_SERVER_ERROR:
                                case ParseException.TIMEOUT:
                                    msg = "server";
                                    break;
                                default:
                                    msg = "unknown";
                            }
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, msg);
                        }
                    }
                });
            }
        });
    }

    @Override
    public void logout() {
    }

    @Override
    public boolean isLogined() {
        return ParseUser.getCurrentUser() != null;
    }

    @Override
    public String getSessionID() {
        if (isLogined()) {
            return ParseUser.getCurrentUser().getUsername();
        }
        return "";
    }

    public String getTwitterID() {
        return ParseTwitterUtils.getTwitter().getUserId();
    }

    public String twitterApi(JSONObject params) {
        String result = "{\"errors\":[{\"message\":\"unknown\",code:999}]}";
        HttpClient client = new DefaultHttpClient();
        try {
            String api = params.getString("Param1");
            params = params.getJSONObject("Param2");
            ArrayList<String> paramsArr = new ArrayList<String>();
            Iterator<String> it = params.keys();
            while (it.hasNext()) {
                String key = it.next();
                String value = params.getString(key);
                paramsArr.add(key + "=" + value);
            }
            HttpGet req = new HttpGet(String.format("https://api.twitter.com/1.1/%s.json?%s", api, TextUtils.join("&", paramsArr)));
            ParseTwitterUtils.getTwitter().signRequest(req);
            result = client.execute(req, new ResponseHandler<String>() {
                @Override
                public String handleResponse(HttpResponse res) throws ClientProtocolException, IOException {
                    switch (res.getStatusLine().getStatusCode()) {
                        case HttpStatus.SC_OK:
                            return EntityUtils.toString(res.getEntity(), "UTF-8");
                        case HttpStatus.SC_NOT_FOUND:
                            throw new RuntimeException("data not found");
                        default:
                            throw new RuntimeException("unknown");
                    }
                }
            });
        } catch(org.json.JSONException e) {
            e.printStackTrace();
        } catch (ClientProtocolException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            client.getConnectionManager().shutdown();
        }
        return result;
    }

    public void cloudFunc(JSONObject params) {
        final InterfaceUser that = this;
        try{
            String name = params.getString("Param1");
            params = params.getJSONObject("Param2");
            Iterator<String> it = params.keys();
            HashMap<String, Object> prms = new HashMap<String, Object>();
            while (it.hasNext()) {
                String key = it.next();
                String value = params.getString(key);
                if (key.equals("twID")) {
                    prms.put(key, Long.parseLong(value));
                } else {
                    prms.put(key, value);
                }
            }
            ParseCloud.callFunctionInBackground(name, prms, new FunctionCallback<String>() {
                public void done(String result, ParseException e) {
                    if (e == null && result != null) {
                        UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, result);
                    } else {
                        UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "error");
                    }
                }
            });
        } catch(org.json.JSONException e) {
            e.printStackTrace();
            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "error");
        }
    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "1.5.1";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }

}
