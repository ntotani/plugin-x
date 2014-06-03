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

import java.io.File;
import java.util.Hashtable;

//import org.cocos2dx.plugin.TwitterApp.TwDialogListener;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import com.facebook.Session;
import com.facebook.Session.NewPermissionsRequest;
import com.facebook.Session.StatusCallback;
import com.facebook.SessionState;

public class ShareFacebook implements InterfaceShare {

	private static final String LOG_TAG = "ShareFacebook";
	private static final String PERMISSION = "publish_actions";
	private static Activity mContext = null;
	private static InterfaceShare mShareAdapter = null;
	protected static boolean bDebug = false;
	
	private static Hashtable<String, String> mShareInfo = null;
	
	public static String KEY_TEXT="SharedText";
	public static String KEY_IMAGE_PATH = "SharedImagePath";

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public ShareFacebook(Context context) {
		mContext = (Activity)context;
		mShareAdapter = this;
	}
	

	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
	}

	@Override
	public void share(Hashtable<String, String> info) {
		LogD("share invoked " + info.toString());
		mShareInfo =  info;
		if (! networkReachable()) {
			shareResult(ShareWrapper.SHARERESULT_FAIL, "Network error!");
			return;
		}
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				tryPost();
			}
		});
	}

	private void tryPost() {
		Session session = Session.getActiveSession();
		if (session.isOpened()) {
			if (session.getPermissions().contains(PERMISSION)) {
				showPostActivity();
			} else {
				requestPermission();
			}
		} else {
			login();
		}
	}

	private void showPostActivity() {
		String message = mShareInfo.get(KEY_TEXT);
		String filePath = "";
		if (mShareInfo.contains(KEY_IMAGE_PATH)) {
				filePath = mShareInfo.get(KEY_IMAGE_PATH);
		}
		Intent intent = new Intent(mContext, FacebookActivity.class);
		intent.putExtra("message", message);
		intent.putExtra("filePath", filePath);
		mContext.startActivity(intent);
	}

	private void requestPermission() {
		Session session = Session.getActiveSession();
		session.requestNewPublishPermissions(new NewPermissionsRequest(mContext, PERMISSION).setCallback(new StatusCallback() {
			@Override
			public void call(Session session, SessionState state, Exception exception) {
				if (state == SessionState.OPENED_TOKEN_UPDATED) {
					tryPost();
				}
			}
		}));
	}

	private void login() {
		StatusCallback callback = new StatusCallback() {
			@Override
			public void call(Session session, SessionState state, Exception exception) {
				if (state == SessionState.OPENED) {
					tryPost();
				}
			}
		};
		Session session = Session.getActiveSession();
		if (!session.isClosed()) {
			session.openForRead(new Session.OpenRequest(mContext).setCallback(callback));
		} else {
			Session.openActiveSession(mContext, true, callback);
		}
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return "Unknown version";
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

	private static void shareResult(int ret, String msg) {
		ShareWrapper.onShareResult(mShareAdapter, ret, msg);
		LogD("ShareFacebook result : " + ret + " msg : " + msg);
	}

	@Override
	public String getPluginVersion() {
		return "0.2.0";
	}
}
