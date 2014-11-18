package org.cocos2dx.plugin;

import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Set;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.File;
import java.nio.channels.FileChannel;

import android.os.Environment;
import android.app.Activity;
import android.content.Context;
import android.content.ContentValues;
import android.content.ContentResolver;
import android.util.Log;
import android.provider.MediaStore;
import android.widget.Toast;

public class AdsUtils implements InterfaceAds {

    private static final String LOG_TAG = "AdsUtils";
    private static Activity mContext = null;
    private static boolean bDebug = false;

    protected static void LogE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public AdsUtils(Context context) {
        mContext = (Activity) context;
    }

    public void saveImage(String path) {
        try {
            File srcFile = new File(path);
            FileChannel src = new FileInputStream(srcFile).getChannel();
            String dstPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).getPath() + "/" + srcFile.getName();
            FileChannel dst = new FileOutputStream(new File(dstPath)).getChannel();
            dst.transferFrom(src, 0, src.size());
            src.close();
            dst.close();
            ContentValues values = new ContentValues();
            values.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
            values.put("_data", dstPath);
            ContentResolver contentResolver = mContext.getContentResolver();
            contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            PluginWrapper.runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(mContext, "画像を保存しました", Toast.LENGTH_LONG).show();
                }
            });
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "0.0.0";
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
    }

    @Override
    public void showAds(Hashtable<String, String> info, int pos) {
    }

    @Override
    public void spendPoints(int points) {
    }

    @Override
    public void hideAds(Hashtable<String, String> info) {
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }

    @Override
    public void queryPoints() {
    }
}
