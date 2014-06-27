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
import android.content.Intent;
import android.util.Log;
import android.preference.PreferenceManager.OnActivityResultListener;

import com.google.example.games.basegameutils.GameHelper;

import org.cocos2dx.lib.Cocos2dxHelper;

public class UserGoogleplay implements InterfaceUser, GameHelper.GameHelperListener, OnActivityResultListener, Cocos2dxHelper.OnActivityStartStopListener, RoomUpdateListener {

    private static final int RC_WAITING_ROOM = 10002;
    private static final String LOG_TAG = "UserGoogleplay";
    private static Activity mContext = null;
    private static UserGoogleplay mGoogleplay = null;
    private static boolean bDebug = false;
    private GameHelper mGameHelper;

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
                mGameHelper = new GameHelper(mContext, GameHelper.CLIENT_GAMES);
                mGameHelper.setup(mGoogleplay);
                mGameHelper.enableDebugLog(bDebug);
                Cocos2dxHelper.addOnActivityStartStopListener(mGoogleplay);
                Cocos2dxHelper.addOnActivityResultListener(mGoogleplay);
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
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mGameHelper.beginUserInitiatedSignIn();
            }
        });
    }

    @Override
    public void logout() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mGameHelper.signOut();
            }
        });
    }

    @Override
    public boolean isLogined() {
        return mGameHelper.isSignedIn();
    }

    @Override
    public String getSessionID() {
        String strRet = "";
        if (isLogined()) {
            strRet = "hoge";
        }
        return strRet;
    }

    @Override
    public void onSignInSucceeded() {
        UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "onSignInSucceeded");
    }

    @Override
    public void onSignInFailed() {
        UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGIN_FAILED, "onSignInFailed");
    }

    @Override
    public void onActivityStart() {
        mGameHelper.onStart(mContext);
    }

    @Override
    public void onActivityStop() {
        mGameHelper.onStop();
    }

    public void createQuickStartRoom() {
        // auto-match criteria to invite one random automatch opponent.  
        // You can also specify more opponents (up to 3). 
        Bundle am = RoomConfig.createAutoMatchCriteria(1, 1, 0);

        // build the room config:
        RoomConfig.Builder roomConfigBuilder = makeBasicRoomConfigBuilder();
        roomConfigBuilder.setAutoMatchCriteria(am);
        RoomConfig roomConfig = roomConfigBuilder.build();

        // create room:
        Games.RealTimeMultiplayer.create(getApiClient(), roomConfig);

        // prevent screen from sleeping during handshake
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    @Override
    public void onRoomCreated(int statusCode, Room room) {
        if (statusCode != GamesStatusCodes.STATUS_OK) {
            // let screen go to sleep
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // show error message, return to main screen.
        }
        // get waiting room intent
        Intent i = Games.RealTimeMultiplayer.getWaitingRoomIntent(getApiClient(), room, Integer.MAX_VALUE);
        startActivityForResult(i, RC_WAITING_ROOM);
    }

    @Override
    public void onJoinedRoom(int statusCode, Room room) {
        if (statusCode != GamesStatusCodes.STATUS_OK) {
            // let screen go to sleep
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // show error message, return to main screen.
        }
        // get waiting room intent
        Intent i = Games.RealTimeMultiplayer.getWaitingRoomIntent(getApiClient(), room, Integer.MAX_VALUE);
        startActivityForResult(i, RC_WAITING_ROOM);
    }

    @Override
    public void onRoomConnected(int statusCode, Room room) {
        if (statusCode != GamesStatusCodes.STATUS_OK) {
            // let screen go to sleep
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // show error message, return to main screen.
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (request == RC_WAITING_ROOM) {
            if (response == Activity.RESULT_OK) {
                // (start game)
                UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "onMatch");
            } else if (response == Activity.RESULT_CANCELED) {
                // Waiting room was dismissed with the back button. The meaning of this
                // action is up to the game. You may choose to leave the room and cancel the
                // match, or do something else like minimize the waiting room and
                // continue to connect in the background.

                // in this example, we take the simple approach and just leave the room:
                Games.RealTimeMultiplayer.leave(getApiClient(), null, mRoomId);
                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            } else if (response == GamesActivityResultCodes.RESULT_LEFT_ROOM) {
                // player wants to leave the room.
                Games.RealTimeMultiplayer.leave(getApiClient(), null, mRoomId);
                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        }
        mGameHelper.onActivityResult(requestCode, resultCode, data);
        return false;
    }

}
