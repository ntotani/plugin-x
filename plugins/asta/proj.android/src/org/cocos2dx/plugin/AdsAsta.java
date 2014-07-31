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

import jp.maru.mrd.IconCell;
import jp.maru.mrd.IconLoader;

import org.cocos2dx.libAdsAsta.R;

public class AdsAsta implements InterfaceAds {

	private static final String LOG_TAG = "AdsAsta";
	private static Activity mContext = null;
	private static boolean bDebug = false;
	private static final int AST_ICON_SIZE = 50;
	private static final int DEVICE_BASE_WIDTH = 360;
	private String _MEDIA_CODE;
	private static IconLoader<Integer> _iconLoader;
	private static RelativeLayout _adMain;

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAsta(Context context) {
		mContext = (Activity) context;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        LogD("Asta:configDeveloperInfo!");
        _MEDIA_CODE = devInfo.get("AstaID");
    }

    public void initAsta(int iconCount, int iconPerLine, float posY) {
        LogD("Asta:initAsta!");
        Activity activity = mContext;
        
        DisplayMetrics metrics = activity.getResources().getDisplayMetrics();
        
        IconLoader<Integer> iconLoader = new IconLoader<Integer>(_MEDIA_CODE, activity);
        iconLoader.setRefreshInterval(15);
        
        //メインレイアウト生成
        final int FILL_PARENT = LinearLayout.LayoutParams.FILL_PARENT;
        final int WRAP_CONTENT = LinearLayout.LayoutParams.WRAP_CONTENT;
        _adMain = new  RelativeLayout(activity);
        _adMain.setGravity(Gravity.CENTER_HORIZONTAL);
        
        RelativeLayout.LayoutParams mainLayoutParams = new RelativeLayout.LayoutParams(FILL_PARENT, FILL_PARENT);
        mainLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        _adMain.setLayoutParams(mainLayoutParams);
        
        //アイコン広告レイアウト
        int iconMargin = (int)(AST_ICON_SIZE * metrics.density * 1.5);
        int iconY = (int)(posY * metrics.density * 1.5);
        LinearLayout iconAdLayout = new LinearLayout(activity);
        RelativeLayout.LayoutParams iconAdLayoutParams = new RelativeLayout.LayoutParams(FILL_PARENT, WRAP_CONTENT);
        iconAdLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        iconAdLayoutParams.setMargins(0, iconY, 0, 0);
        iconAdLayout.setLayoutParams(iconAdLayoutParams);
        iconAdLayout.setGravity(Gravity.CENTER_HORIZONTAL);
        
        for (int i = 0; i < iconCount; i++) {
            if (i > 0 && i % iconPerLine == 0) {
                //行替え
                iconY += iconMargin;
                _adMain.addView(iconAdLayout);
                
                //アイコン広告レイアウト
                iconAdLayout = new LinearLayout(activity);
                iconAdLayoutParams = new RelativeLayout.LayoutParams(FILL_PARENT, WRAP_CONTENT);
                iconAdLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                iconAdLayoutParams.setMargins(0, iconY, 0, 0);
                iconAdLayout.setLayoutParams(iconAdLayoutParams);
                iconAdLayout.setGravity(Gravity.CENTER_HORIZONTAL);
            }
            final LinearLayout iconAdSubLayout = new LinearLayout(activity);
            LinearLayout.LayoutParams iconAdSubLayoutParams = new LinearLayout.LayoutParams(1, iconMargin, 1.0f);
            iconAdSubLayout.setLayoutParams(iconAdSubLayoutParams);
            
            View iconView = activity.getLayoutInflater().inflate(R.layout.org_cocos2dx_plugin_asta_icon, null);
            ((IconCell)iconView).setShouldDrawTitle(false);
            ((IconCell)iconView).addToIconLoader(iconLoader);
            iconAdSubLayout.addView(iconView);
            iconAdLayout.addView(iconAdSubLayout);
        }
        _adMain.addView(iconAdLayout);
        _adMain.setVisibility(View.GONE);
        View contentView = ((ViewGroup)activity.findViewById(android.R.id.content)).getChildAt(0);
        ((ViewGroup)contentView).addView(_adMain);
        
        _iconLoader = iconLoader;
    }

	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
        
        final int iconCount = Integer.parseInt(info.get("iconCount"));
        final int iconPerLine = Integer.parseInt(info.get("iconPerLine"));
        final float posY = Float.parseFloat(info.get("posY"));
        
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
                LogD("Asta:showAds!");
                if (_iconLoader == null) {
                    initAsta(iconCount, iconPerLine, posY);
                }
                _iconLoader.startLoading();
                _adMain.setVisibility(View.VISIBLE);
			}
		});
	}

    @Override
    public void hideAds(Hashtable<String, String> info) {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                LogD("Asta:hideAds!");
                if (_iconLoader != null) {
                    _iconLoader.stopLoading();
                    _adMain.setVisibility(View.GONE);
                }
            }
        });
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
		LogD("Asta not support query points!");
	}

	@Override
	public void spendPoints(int points) {
		LogD("Asta not support spend points!");
	}

}
