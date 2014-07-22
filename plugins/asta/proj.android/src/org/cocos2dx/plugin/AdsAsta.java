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
  private static final int AST_ICON_WIDTH = 50;
  private static final int DEVICE_BASE_WIDTH = 360;
  private String _MEDIA_CODE;
  private int AST_ICON_COUNT;
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
      _MEDIA_CODE = devInfo.get("AstaID");
      AST_ICON_COUNT = Integer.parseInt(devInfo.get("iconCount"));
  }

  public void initAsta() {
      Activity activity = mContext;

      _adMain = new  RelativeLayout(activity);
      LinearLayout iconAdView = new LinearLayout(activity);

      DisplayMetrics metrics = activity.getResources().getDisplayMetrics();
      RelativeLayout.LayoutParams layoutParams;
      final int FILL_PARENT = LinearLayout.LayoutParams.FILL_PARENT;
      layoutParams = new RelativeLayout.LayoutParams(FILL_PARENT, (int)(AST_ICON_WIDTH * metrics.density));

      layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
      iconAdView.setGravity(Gravity.CENTER_HORIZONTAL);
      iconAdView.setLayoutParams(layoutParams);

      IconLoader<Integer> iconLoader = new IconLoader<Integer>(_MEDIA_CODE, activity);
      iconLoader.setRefreshInterval(15);

      for (int i = 0; i < AST_ICON_COUNT; i++) {
          final LinearLayout iconAdSubView = new LinearLayout(activity);
          LinearLayout.LayoutParams layoutSubParams =
              new LinearLayout.LayoutParams(1, (int)(AST_ICON_WIDTH * metrics.density), 1.0f);

          int width = metrics.widthPixels;
          int icon_width = (int)(DEVICE_BASE_WIDTH * metrics.density + 0.5f);
          if(width - icon_width > 0) {
              int iconMargin = (int)((width - icon_width) / (AST_ICON_COUNT * 2));
              layoutSubParams.setMargins(iconMargin, 0, iconMargin, 0);
          }
          iconAdSubView.setLayoutParams(layoutSubParams);

          //IconCell view = new IconCell(activity);
          //view.setLayoutParams(new LinearLayout.LayoutParams(80, 80));
          View view = activity.getLayoutInflater().inflate(R.layout.org_cocos2dx_plugin_asta_icon, null);
          ((IconCell)view).setShouldDrawTitle(false);
          ((IconCell)view).addToIconLoader(iconLoader);
          iconAdSubView.addView(view);
          iconAdView.addView(iconAdSubView);
      }
      _adMain.addView(iconAdView);
      _adMain.setVisibility(View.GONE);
      View contentView = ((ViewGroup)activity.findViewById(android.R.id.content)).getChildAt(0);
      ((ViewGroup)contentView).addView(_adMain);
      _iconLoader = iconLoader;
  }

	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
          if (_iconLoader == null) {
              initAsta();
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
