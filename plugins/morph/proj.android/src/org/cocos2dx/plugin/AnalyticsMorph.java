package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.content.Context;
import android.util.Log;

import net.reduls.sanmoku.Morpheme;
import net.reduls.sanmoku.Tagger;

public class AnalyticsMorph implements InterfaceAnalytics {

    private Context mContext = null;
    protected static String TAG = "AnalyticsMorph";

    protected static void LogE(String msg, Exception e) {
        Log.e(TAG, msg, e);
        e.printStackTrace();
    }

    private static boolean isDebug = false;
    protected static void LogD(String msg) {
        if (isDebug) {
            Log.d(TAG, msg);
        }
    }

    public AnalyticsMorph(Context context) {
        mContext = context;
    }

    public String parseNoun(String text) {
        StringBuilder sb = new StringBuilder("[");
        for (Morpheme e : Tagger.parse(text)) {
            String[] surface = e.surface.split(",");
            if (surface[0].equals("名詞") && e.feature.length() > 2) {
                sb.append("\"").append(e.feature).append("\",");
            }
        }
        if (sb.length() > 1) {
            sb.deleteCharAt(sb.length() - 1);
        }
        sb.append("]");
        return sb.toString();
    }

    @Override
    public void startSession(String appKey) {
        LogD("startSession invoked!");
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            }
        });
    }

    @Override
    public void stopSession() {
        LogD("stopSession invoked!");
    }

    @Override
    public void setSessionContinueMillis(int millis) {
        LogD("setSessionContinueMillis invoked!");
    }

    @Override
    public void setCaptureUncaughtException(boolean isEnabled) {
        LogD("setCaptureUncaughtException invoked!");
    }

    @Override
    public void setDebugMode(boolean isDebugMode) {
        isDebug = isDebugMode;
    }

    @Override
    public void logError(String errorId, String message) {
        LogD("logError invoked!");
    }

    @Override
    public void logEvent(String eventId) {
        LogD("logEvent(eventId) invoked!");
    }

    @Override
    public void logEvent(String eventId, Hashtable<String, String> paramMap) {
        LogD("logEvent(eventId, paramMap) invoked!");
    }

    @Override
    public void logTimedEventBegin(String eventId) {
        LogD("logTimedEventBegin invoked!");
    }

    @Override
    public void logTimedEventEnd(String eventId) {
        LogD("logTimedEventEnd invoked!");
    }

    @Override
    public String getSDKVersion() {
        return "0.0.5";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }
}
