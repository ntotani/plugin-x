package org.cocos2dx.plugin;

import java.util.Hashtable;
import java.util.List;

import org.json.JSONObject;
import org.json.JSONArray;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.parse.Parse;
import com.parse.ParseUser;
import com.parse.ParseTwitterUtils;
import com.parse.ParseException;
import com.parse.LogInCallback;
import com.parse.ParseQuery;
import com.parse.CountCallback;
import com.parse.FindCallback;
import com.parse.ParseObject;

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
        final InterfaceUser that = this;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                ParseTwitterUtils.logIn(mActivity, new LogInCallback() {
                    public void done(ParseUser user, ParseException e) {
                        if (e == null && user != null) {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_SUCCEED, user.getUsername());
                        } else if (user == null) {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "usernameOrPasswordIsInvalid");
                        } else {
                            UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGIN_FAILED, "somethingWentWrong");
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

    public void enableAutomaticUser() {
        ParseUser.enableAutomaticUser();
    }

    public void saveUserAttr(JSONObject args) {
        try {
            ParseUser user = ParseUser.getCurrentUser();
            user.put("runCount", Integer.parseInt(args.getString("Param1")));
            user.put("goalCount", Integer.parseInt(args.getString("Param2")));
            user.put("cupCount", Integer.parseInt(args.getString("Param3")));
            user.saveInBackground();
        } catch(org.json.JSONException e) {
            LogE("Exception in saveUserAttr", e);
        }
    }

    public int getUserAttr(String attr) {
        return Integer.parseInt(ParseUser.getCurrentUser().get(attr).toString());
    }

    public void fetchUserRank(String col) {
        final InterfaceUser that = this;
        ParseQuery<ParseUser> query = ParseUser.getQuery();
        query.whereGreaterThan(col, getUserAttr(col));
        query.countInBackground(new CountCallback() {
            public void done(int count, ParseException e) {
                if (e == null) {
                    // The query was successful.
                    UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, String.format("{\"rank\":%d}", count + 1));
                } else {
                    // Something went wrong.
                    UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, String.format("{\"rank\":%d}", 0));
                }
            }
        });
    }

    public void fetchScoreRank(String col) {
        final InterfaceUser that = this;
        ParseQuery<ParseUser> query = ParseUser.getQuery();
        query.setLimit(100);
        query.orderByDescending(col);
        final String _col = col;
        query.findInBackground(new FindCallback<ParseUser>() {
            public void done(List<ParseUser> users, ParseException e) {
                if (e == null) {
                    JSONArray arr = new JSONArray();
                    for (ParseObject user : users) {
                        arr.put(Integer.parseInt(user.get(_col).toString()));
                    }
                    UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, arr.toString());
                } else {
                    LogE(e.getMessage(), e);
                    UserWrapper.onActionResult(that, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "[]");
                }
            }
        });
    }

}
