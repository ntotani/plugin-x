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
import android.net.Uri;
import android.util.Log;
import android.provider.MediaStore;
import android.app.AlertDialog;
import android.content.DialogInterface;
import java.io.File;

import org.json.JSONObject;

public class ShareLine implements InterfaceShare {

    private static final String LOG_TAG = "ShareLine";
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

    public ShareLine(Context context) {
      mContext = (Activity) context;
      mShareAdapter = this;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
        LogD("initDeveloperInfo invoked " + cpInfo.toString());
    }

    @Override
    public void share(Hashtable<String, String> info) {
        LogD("share invoked " + info.toString());
        mShareInfo =  info;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                String text = mShareInfo.get(KEY_TEXT);
                String imagePath = mShareInfo.get(KEY_IMAGE_PATH);
                
                File f = new File(imagePath);
                if(f.exists()) {
                    //他のアプリからこの画像を読めるようにする
                    f.setReadable(true, false);
                    
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setData(Uri.parse("line://msg/image/" + imagePath));
                    mContext.startActivity(intent);
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
        return "Unknown version";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }
    
    public void saveImageToGallery(JSONObject params) {
        try {
            final String imgPath = params.getString("imagePath");
            
            PluginWrapper.runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    
                    String uriStr;
                    try {
                        uriStr = MediaStore.Images.Media.insertImage(mContext.getContentResolver(), imgPath, "", "");
                        if(uriStr!=null) {
                            //保存成功
                            AlertDialog.Builder dialog = new AlertDialog.Builder(mContext);
                            dialog.setTitle("");
                            dialog.setMessage("保存しました。");
                            dialog.setPositiveButton("OK",new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,int whichButton) {
                                }
                            });
                            dialog.create();
                            dialog.show();
                            
                        } else {
                            //保存失敗
                            AlertDialog.Builder dialog = new AlertDialog.Builder(mContext);
                            dialog.setTitle("エラー");
                            dialog.setMessage("保存に失敗しました。");
                            dialog.setPositiveButton("OK",new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,int whichButton) {
                                }
                            });
                            dialog.create();
                            dialog.show();
                        }
                        
                    }  catch (Exception e) {
                        //エラー
                        AlertDialog.Builder dialog = new AlertDialog.Builder(mContext);
                        dialog.setTitle("エラー");
                        dialog.setMessage("保存に失敗しました。");
                        dialog.setPositiveButton("OK",new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog,int whichButton) {
                            }
                        });
                        dialog.create();
                        dialog.show();
                        LogE("Media.insertImage error", e);
                    }
                }
            });
        } catch (org.json.JSONException e) {
            LogE("invalid param", e);
        }
    }

}
