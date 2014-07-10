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

import jp.live_aid.aid.AdController;

public class AdsAid implements InterfaceAds {

	private static final String LOG_TAG = "AdsAid";
	private static Activity mContext = null;
	private static boolean bDebug = false;
    private static String AppId = "";
    private static AdController _aidAdController;
    
	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAid(Context context) {
		mContext = (Activity) context;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        LogD("AdsAid configDeveloperInfo!");
        AppId = devInfo.get("AidID");
	}
    
    public void initAid() {
        Activity activity = mContext;
        _aidAdController = new AdController(AppId, activity);
    }
    
	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
        final String mode = info.get("mode");
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
                LogD("AdsAid showAds!");
                if (_aidAdController == null) {
                    initAid();
                }
                if (mode == "text") {
                    //テキスト型広告
                    _aidAdController.setCreativeStyle(AdController.CreativeStyle.PLAIN_TEXT);
                } else if (mode == "image") {
                    //画像ポップアップ型
                    _aidAdController.setCreativeStyle(AdController.CreativeStyle.POPUP_IMAGE);
                }
                _aidAdController.startPreloading();
                _aidAdController.stopPreloading();
                _aidAdController.showDialog(AdController.DialogType.ON_DEMAND);
			}
		});
	}

	@Override
	public void hideAds(Hashtable<String, String> info) {
        LogD("Aid not support hideAds!");
	}

    @Override
	public void spendPoints(int points) {
		LogD("Aid not support spend points!");
	}
    
    @Override
	public void queryPoints() {
		LogD("Aid not support query points!");
	}
    
	@Override
	public String getSDKVersion() {
		return "1.1.1";
	}
    
	@Override
	public String getPluginVersion() {
		return "0.0.1";
	}
}
