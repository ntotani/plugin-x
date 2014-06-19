/****************************************************************************
  Copyright (c) 2012-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

public class UserGoogleplay implements InterfaceUser {

    private static final String LOG_TAG = "UserGoogleplay";
    private static Activity mContext = null;
    private static UserGoogleplay mGoogleplay = null;
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

    public UserGoogleplay(Context context) {
        mContext = (Activity) context;
        mGoogleplay = this;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
        LogD("initDeveloperInfo invoked " + cpInfo.toString());
        final Hashtable<String, String> curCPInfo = cpInfo;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                try {
                    //String clientId = curCPInfo.get("ClientID");
                } catch (Exception e) {
                    LogE("Developer info is wrong!", e);
                }
            }
        });
    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "1.0.0";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }

    @Override
    public void login() {
        if (isLogined()) {
            UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "Already logined!");
            return;
        }

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // login
            }
        });
    }

    @Override
    public void logout() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // logout
                UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "User logout");
            }
        });
    }

    @Override
    public boolean isLogined() {
        return true;
    }

    @Override
    public String getSessionID() {
        String strRet = "";
        if (isLogined()) {
            strRet = "hoge";
        }
        return strRet;
    }
}
