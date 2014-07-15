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
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.appvador.ad.*;

public class AdsAppvador implements InterfaceAds {

	private static final String LOG_TAG = "AdsAppvador";
	private static Activity mContext = null;
	private static boolean bDebug = false;
    private static AdView _adView = null;
    private static String bannerAppId = "";
    private static RelativeLayout _adMain = null;
    private static AdsAppvador mAdapter = null;
    
	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAppvador(Context context) {
		mContext = (Activity) context;
        mAdapter = this;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        bannerAppId = devInfo.get("AppvadorBannerID");
	}
    
    public void removeAdView() {
        LogD("AppVador removeMainView!");
        
        _adView.stop();
        _adMain.removeView(_adView);
        _adView = null;
        
        Activity activity = mContext;
        View contentView = ((ViewGroup)activity.findViewById(android.R.id.content)).getChildAt(0);
        ((ViewGroup)contentView).removeView(_adMain);
        _adMain = null;
    }
    
    public void initAppvador() {
        LogD("AppVador hide!");
        
        Activity activity = mContext;
        _adView = new AdView(activity, bannerAppId, false, bDebug);
        _adView.setAdListener(new AppvadorAdsListener());
        
        _adMain = new RelativeLayout(activity);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        
        _adView.setVisibility(View.INVISIBLE);
        _adMain.addView(_adView, layoutParams);
        
        View contentView = ((ViewGroup)activity.findViewById(android.R.id.content)).getChildAt(0);
        ((ViewGroup)contentView).addView(_adMain);
    }

	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
                if (_adMain != null) {
                    removeAdView();
                }
                initAppvador();
                
                _adView.setVisibility(View.VISIBLE);
                _adView.adStart();
			}
		});
	}

	@Override
	public void hideAds(Hashtable<String, String> info) {
        PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
                LogD("AppVador hideAds!");
                if (_adMain != null) {
                    LogD("AppVador hide!");
                    //削除
                    removeAdView();
                    //削除するとなぜか音が調整できなくなるので、initして非表示にしておく
                    initAppvador();
                }
			}
		});
	}

    @Override
	public void spendPoints(int points) {
		LogD("AppVador not support spend points!");
	}
    
    private class AppvadorAdsListener implements AdListener {
        
        @Override
        public void detachedFromWindow(AdResult args0) {
            LogD("AppVador detachedFromWindow!");
        }
        
        //広告の取得に成功
        @Override
        public void adLoadSucceeded(AdResult args0) {
            LogD("AppVador adLoadSucceeded!");
        }
        
        //広告の取得に失敗
        @Override
        public void failedToReceiveAd(AdResult args0) {
            LogD("AppVador failedToReceiveAd!");
            //削除
            _adView.stop();
            _adMain.removeView(_adView);
            _adView = null;
            
            Activity activity = mContext;
            View contentView = ((ViewGroup)activity.findViewById(android.R.id.content)).getChildAt(0);
            ((ViewGroup)contentView).removeView(_adMain);
            _adMain = null;
            
            AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_UnknownError, "banner");
        }
        
        //広告がタップされた際に呼ばれます
        @Override
        public void adDidTap(AdResult args0) {
            LogD("AppVador adDidTap!");
        }
	}
    
    @Override
	public void queryPoints() {
		LogD("AppVador not support query points!");
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
