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

import com.amoad.amoadsdk.AMoAdSdk;
import com.amoad.amoadsdk.AMoAdSdkWallActivity;

public class AdsAmoad implements InterfaceAds {

	private static final String LOG_TAG = "AdsAmoad";
	private static Activity mContext = null;
	private static boolean bDebug = false;

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAmoad(Context context) {
		mContext = (Activity) context;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		AMoAdSdk.sendUUID(mContext);
	}

	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Intent intent = new Intent(mContext, AMoAdSdkWallActivity.class);
				mContext.startActivity(intent);
			}
		});
	}

	@Override
	public void hideAds(Hashtable<String, String> info) {
		LogD("Amoad not support hideAds!");
	}

	@Override
	public String getSDKVersion() {
		return "20140501";
	}

	@Override
	public String getPluginVersion() {
		return "0.0.1";
	}

	@Override
	public void queryPoints() {
		LogD("Amoad not support query points!");
	}

	@Override
	public void spendPoints(int points) {
		LogD("Amoad not support spend points!");
	}

  public boolean isFirstTimeInToday() {
      return AMoAdSdk.isFirstOnToday(mContext);
  }

}
