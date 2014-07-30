package org.cocos2dx.plugin;

import android.app.PendingIntent;
import android.app.Notification;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import android.util.Log;

public class LocalNotificationReceiver extends BroadcastReceiver
{
    public void onReceive(Context context, Intent intent)
    {
        try {
            String message = intent.getStringExtra("message");
            Intent intent2 = new Intent(context, Class.forName("org.cocos2dx.lua.AppActivity"));
            PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent2, PendingIntent.FLAG_UPDATE_CURRENT);
            Notification.Builder builder = new Notification.Builder(context)
                .setContentTitle("info")
                .setContentText(message)
                .setContentIntent(pendingIntent)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setDefaults(Notification.DEFAULT_ALL)
                .setAutoCancel(true);
            NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.notify(0, builder.build());
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
