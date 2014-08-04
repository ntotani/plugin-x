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
import android.view.View;

import jp.live_aid.aid.AdController;

public class AdsAid implements InterfaceAds {

	private static final String LOG_TAG = "AdsAid";
	private static Activity mContext = null;
	private static boolean bDebug = false;
    private static String AppId = "";
    private static String AppIdCp = "";
    private static String AppIdInterstitial = "";
    private static AdController _targetController;
    private static AdController _aidAdController;
    private static AdController _aidAdControllerCp;
    private static AdController _aidAdControllerInterstitial;
    private static AdsAid mAdapter = null;
    
	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAid(Context context) {
		mContext = (Activity) context;
        mAdapter = this;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        LogD("AdsAid configDeveloperInfo!");
        AppId = devInfo.get("AidID");
        AppIdCp = devInfo.get("AidIDCp");
        AppIdInterstitial = devInfo.get("AidIDInterstitial");
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                initAid();
                initAidCp();
                initAidInterstitial();
            }
        });
	}
    
    public void initAid() {
        LogD("AdsAid initAid!");
        Activity activity = mContext;
        if (!AppId.isEmpty()) {
            LogD("AdsAid gen _aidAdController!");
            _aidAdController = new AdController(AppId, activity);
            _aidAdController.setCreativeStyle(AdController.CreativeStyle.PLAIN_TEXT);
            _aidAdController.startPreloading();
        }
    }
    
    public void initAidCp() {
        LogD("AdsAid initAidCp!");
        Activity activity = mContext;
        if (!AppIdCp.isEmpty()) {
            LogD("AdsAid gen _aidAdControllerCp!");
            _aidAdControllerCp = new AdController(AppIdCp, activity) {
                
                //ポップアップの閉じるボタン押した
                protected void dialogCloseButtonWasClicked(android.app.Dialog dialog, View view) {
                    LogD("AdsAid dialogCloseButtonWasClicked!");
                    super.dialogCloseButtonWasClicked(dialog, view);
                    AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsReceived, "tap_btn_close");
                }
                //ポップアップの詳細をみるボタン押した
                protected void dialogDetailButtonWasClicked(android.app.Dialog dialog, View view) {
                    LogD("AdsAid dialogDetailButtonWasClicked!");
                    super.dialogDetailButtonWasClicked(dialog, view);
                    AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsReceived, "tap_btn_detail");
                }
                //backボタンでのポップアップキャンセルを不可にします
                protected void dialogDidCreated(android.app.Dialog dialog) {
                    dialog.setCancelable(false);
                }
            };
            _aidAdControllerCp.setCreativeStyle(AdController.CreativeStyle.PLAIN_TEXT);
            _aidAdControllerCp.startPreloading();
        }
    }

    public void initAidInterstitial() {
        LogD("AdsAid initAid!");
        Activity activity = mContext;
        if (!AppIdInterstitial.isEmpty()) {
            LogD("AdsAid gen _aidAdController!");
            _aidAdControllerInterstitial = new AdController(AppIdInterstitial, activity);
            _aidAdControllerInterstitial.setCreativeStyle(AdController.CreativeStyle.POPUP_IMAGE);
            _aidAdControllerInterstitial.startPreloading();
        }
    }
    
	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
        final String mode = info.get("mode");
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
                LogD("AdsAid showAds!");
                AdController.DialogType instType = AdController.DialogType.ON_DEMAND;
                if (mode != null && mode.equals("cp")) {
                    LogD("AdsAid cpMode!");
                    _targetController = _aidAdControllerCp;
                } else if (mode != null && mode.equals("interstitial")) {
                    _targetController = _aidAdControllerInterstitial;
                } else if (mode != null && mode.equals("exit")) {
                    _targetController = _aidAdControllerInterstitial;
                    instType = AdController.DialogType.ON_EXIT;
                } else {
                    LogD("AdsAid not cpMode!");
                    _targetController = _aidAdController;
                }
                
                if (_targetController != null) {
                    if (_targetController.hasLoadedContent()) {
                        _targetController.showDialog(instType);
                    } else {
                        final AdController.DialogType dt = instType;
                        new Thread(new Runnable(){
                            public void run(){
                                try
                                {
                                    long started = System.currentTimeMillis();
                                    while (true) {
                                        // 広告がロードされていなければ、最大10秒待つ
                                        if (_targetController.hasLoadedContent()) break;
                                        if (started + 10000L < System.currentTimeMillis()) break;
                                        Thread.sleep(500L);
                                    }
                                }
                                catch(InterruptedException iex) {}
                                
                                PluginWrapper.runOnMainThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        //広告ダイアログを表示
                                        _targetController.showDialog(dt);
                                    }
                                });
                            }
                        }).start();
                    }
                }
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

  public void startPreloading() {
      PluginWrapper.runOnMainThread(new Runnable() {
          @Override
          public void run() {
              if (_aidAdController != null) _aidAdController.startPreloading();
              if (_aidAdControllerCp != null) _aidAdControllerCp.startPreloading();
              if (_aidAdControllerInterstitial != null) _aidAdControllerInterstitial.startPreloading();
          }
      });
  }

  public void stopPreloading() {
      PluginWrapper.runOnMainThread(new Runnable() {
          @Override
          public void run() {
              if (_aidAdController != null) _aidAdController.stopPreloading();
              if (_aidAdControllerCp != null) _aidAdControllerCp.stopPreloading();
              if (_aidAdControllerInterstitial != null) _aidAdControllerInterstitial.stopPreloading();
          }
      });
  }
}
