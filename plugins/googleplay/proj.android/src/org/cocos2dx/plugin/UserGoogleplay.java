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
import java.util.List;
import java.util.ArrayList;

import android.os.Bundle;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.preference.PreferenceManager.OnActivityResultListener;
import android.view.WindowManager;

import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesStatusCodes;
import com.google.android.gms.games.GamesActivityResultCodes;
import com.google.android.gms.games.multiplayer.Multiplayer;
import com.google.android.gms.games.multiplayer.Invitation;
import com.google.android.gms.games.multiplayer.Participant;
import com.google.android.gms.games.multiplayer.realtime.Room;
import com.google.android.gms.games.multiplayer.realtime.RoomConfig;
import com.google.android.gms.games.multiplayer.realtime.RoomUpdateListener;
import com.google.android.gms.games.multiplayer.realtime.RealTimeMessage;
import com.google.android.gms.games.multiplayer.realtime.RealTimeMessageReceivedListener;
import com.google.android.gms.games.multiplayer.realtime.RoomStatusUpdateListener;
import com.google.example.games.basegameutils.GameHelper;

import org.cocos2dx.lib.Cocos2dxHelper;

public class UserGoogleplay implements InterfaceUser, GameHelper.GameHelperListener, OnActivityResultListener, Cocos2dxHelper.OnActivityStartStopListener, RoomUpdateListener, RealTimeMessageReceivedListener, RoomStatusUpdateListener {

    private static final int RC_SELECT_PLAYERS   = 10000;
    private static final int RC_INVITATION_INBOX = 10001;
    private static final int RC_WAITING_ROOM     = 10002;
    private static final String LOG_TAG = "UserGoogleplay";
    private static Activity mContext = null;
    private static UserGoogleplay mGoogleplay = null;
    private static boolean bDebug = false;
    private GameHelper mGameHelper;
    private Room roomToTrack;

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

    @Override
    public void onJoinedRoom(int statusCode, Room room) {
        LogD("onJoinedRoom");
        if (statusCode != GamesStatusCodes.STATUS_OK) {
            // let screen go to sleep
            mContext.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // show error message, return to main screen.
        } else {
            roomToTrack = room;
            // get waiting room intent
            Intent i = Games.RealTimeMultiplayer.getWaitingRoomIntent(mGameHelper.getApiClient(), room, Integer.MAX_VALUE);
            mContext.startActivityForResult(i, RC_WAITING_ROOM);
        }
    }

    @Override
    public void onLeftRoom(int statusCode, String roomId) {
        LogD("onLeftRoom");
        mContext.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    @Override
    public void onRoomConnected(int statusCode, Room room) {
        LogD("onRoomConnected");
        if (statusCode != GamesStatusCodes.STATUS_OK) {
            // let screen go to sleep
            mContext.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // show error message, return to main screen.
        }
    }

    @Override
    public void onRoomCreated(int statusCode, Room room) {
        LogD("onRoomCreated");
        if (statusCode != GamesStatusCodes.STATUS_OK) {
            // let screen go to sleep
            mContext.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // show error message, return to main screen.
        } else {
            roomToTrack = room;
            // get waiting room intent
            Intent i = Games.RealTimeMultiplayer.getWaitingRoomIntent(mGameHelper.getApiClient(), room, Integer.MAX_VALUE);
            mContext.startActivityForResult(i, RC_WAITING_ROOM);
        }
    }

    @Override public void onConnectedToRoom(Room room) { LogD("onConnectedToRoom"); }
    @Override public void onDisconnectedFromRoom(Room room) { LogD("onDisconnectedFromRoom"); }
    @Override public void onP2PConnected(String participantId) { LogD("onP2PConnected"); }
    @Override public void onP2PDisconnected(String participantId) { LogD("onP2PDisconnected"); }
    @Override public void onPeerDeclined(Room room, List<String> participantIds) { LogD("onPeerDeclined"); }
    @Override public void onPeerInvitedToRoom(Room room, List<String> participantIds) { LogD("onPeerInvitedToRoom"); }
    @Override public void onPeerJoined(Room room, List<String> participantIds) { LogD("onPeerJoined"); }
    @Override public void onPeerLeft(Room room, List<String> participantIds) {
        LogD("onPeerLeft"); 
        UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "onLeft");
    }
    @Override public void onPeersConnected(Room room, List<String> participantIds) { LogD("onPeersConnected"); }
    @Override public void onPeersDisconnected(Room room, List<String> participantIds) { LogD("onPeersDisconnected"); }
    @Override public void onRoomAutoMatching(Room room) { LogD("onRoomAutoMatching"); }
    @Override public void onRoomConnecting(Room room) { LogD("onRoomConnecting"); }
    
    @Override
    public boolean onActivityResult(int request, int response, Intent data) {
        mGameHelper.onActivityResult(request, response, data);
        if (request == RC_WAITING_ROOM) {
            LogD("onActivityResult");
            if (response == Activity.RESULT_OK) {
                String myName = "";
                String hisName = "";
                String myId = Games.Players.getCurrentPlayerId(mGameHelper.getApiClient());
                for (Participant p : roomToTrack.getParticipants()) {
                    if (p.getPlayer() != null && p.getPlayer().getPlayerId().equals(myId)) {
                        myName = p.getDisplayName();
                    } else {
                        hisName = p.getDisplayName();
                    }
                }
                UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "onMatch " + myName + ":" + hisName);
            } else if (response == Activity.RESULT_CANCELED) {
                // Waiting room was dismissed with the back button. The meaning of this
                // action is up to the game. You may choose to leave the room and cancel the
                // match, or do something else like minimize the waiting room and
                // continue to connect in the background.

                // in this example, we take the simple approach and just leave the room:
                Games.RealTimeMultiplayer.leave(mGameHelper.getApiClient(), this, roomToTrack.getRoomId());
                mContext.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            } else if (response == GamesActivityResultCodes.RESULT_LEFT_ROOM) {
                // player wants to leave the room.
                Games.RealTimeMultiplayer.leave(mGameHelper.getApiClient(), this, roomToTrack.getRoomId());
                mContext.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
            return true;
        } else if (request == RC_SELECT_PLAYERS) {
            if (response != Activity.RESULT_OK) {
                // user canceled
                return false;
            }

            // get the invitee list
            Bundle extras = data.getExtras();
            final ArrayList<String> invitees =
                data.getStringArrayListExtra(Games.EXTRA_PLAYER_IDS);

            // get auto-match criteria
            Bundle autoMatchCriteria = null;
            int minAutoMatchPlayers =
                data.getIntExtra(Multiplayer.EXTRA_MIN_AUTOMATCH_PLAYERS, 0);
            int maxAutoMatchPlayers =
                data.getIntExtra(Multiplayer.EXTRA_MAX_AUTOMATCH_PLAYERS, 0);

            if (minAutoMatchPlayers > 0) {
                autoMatchCriteria =
                    RoomConfig.createAutoMatchCriteria(
                            minAutoMatchPlayers, maxAutoMatchPlayers, 0);
            } else {
                autoMatchCriteria = null;
            }

            // create the room and specify a variant if appropriate
            RoomConfig.Builder roomConfigBuilder = makeBasicRoomConfigBuilder();
            roomConfigBuilder.addPlayersToInvite(invitees);
            if (autoMatchCriteria != null) {
                roomConfigBuilder.setAutoMatchCriteria(autoMatchCriteria);
            }
            RoomConfig roomConfig = roomConfigBuilder.build();
            Games.RealTimeMultiplayer.create(mGameHelper.getApiClient(), roomConfig);

            // prevent screen from sleeping during handshake
            mContext.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        } else if (request == RC_INVITATION_INBOX) {
            if (response != Activity.RESULT_OK) {
                // canceled
                return false;
            }

            // get the selected invitation
            Bundle extras = data.getExtras();
            Invitation invitation = extras.getParcelable(Multiplayer.EXTRA_INVITATION);

            // accept it!
            RoomConfig roomConfig = makeBasicRoomConfigBuilder()
                .setInvitationIdToAccept(invitation.getInvitationId())
                .build();
            Games.RealTimeMultiplayer.join(mGameHelper.getApiClient(), roomConfig);

            // prevent screen from sleeping during handshake
            mContext.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

            // go to game screen
        }
        return false;
    }

    @Override
    public void onRealTimeMessageReceived(RealTimeMessage message) {
        byte[] data = message.getMessageData();
        try {
            String mes = new String(data, "UTF-8");
            LogD(mes);
            UserWrapper.onActionResult(mGoogleplay, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, mes);
        } catch(java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    public void showInviteRoom() {
     PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // launch the intent to show the invitation inbox screen
                Intent intent = Games.Invitations.getInvitationInboxIntent(mGameHelper.getApiClient());
                mContext.startActivityForResult(intent, RC_INVITATION_INBOX);
            }
        });
    }

    public void createQuickStartRoom() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                // auto-match criteria to invite one random automatch opponent.  
                // You can also specify more opponents (up to 3). 
                Bundle am = RoomConfig.createAutoMatchCriteria(1, 1, 0);

                // build the room config:
                RoomConfig.Builder roomConfigBuilder = makeBasicRoomConfigBuilder();
                roomConfigBuilder.setAutoMatchCriteria(am);
                RoomConfig roomConfig = roomConfigBuilder.build();

                // create room:
                Games.RealTimeMultiplayer.create(mGameHelper.getApiClient(), roomConfig);

                // prevent screen from sleeping during handshake
                mContext.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
    }

    public RoomConfig.Builder makeBasicRoomConfigBuilder() {
        return RoomConfig.builder(mGoogleplay)
            .setMessageReceivedListener(mGoogleplay)
            .setRoomStatusUpdateListener(mGoogleplay);
    }

    public void createNormalInviteRoom() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Intent intent = Games.RealTimeMultiplayer.getSelectOpponentsIntent(mGameHelper.getApiClient(), 1, 1);
                mContext.startActivityForResult(intent, RC_SELECT_PLAYERS);
            }
        });
    }

    public void leaveRoom() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Games.RealTimeMultiplayer.leave(mGameHelper.getApiClient(), mGoogleplay, roomToTrack.getRoomId());
            }
        });
    }

    public void sendMessage(String message) {
        try {
            final byte[] data = message.getBytes("UTF-8");
            PluginWrapper.runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    Games.RealTimeMultiplayer.sendUnreliableMessageToOthers(mGameHelper.getApiClient(), data, roomToTrack.getRoomId());
                }
            });
        } catch(java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

}
