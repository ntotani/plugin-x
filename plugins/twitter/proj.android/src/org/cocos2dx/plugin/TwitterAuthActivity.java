package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import twitter4j.*;
import twitter4j.auth.*;

public class TwitterAuthActivity extends Activity {
    
    private final String CALLBACK_URL = "net-uracon-rkyun://twitter-auth-callback";
    private AsyncTwitter twttr;
    private RequestToken requestToken;
    private TwitterAdapter adapter = new TwitterAdapter() {

        @Override
        public void gotOAuthRequestToken(RequestToken token){
            requestToken = token;
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(token.getAuthorizationURL()));
            startActivity(intent);
        }

        @Override
        public void gotOAuthAccessToken(AccessToken token){
            finish();
            UserTwitter.instance.onLoginSuccess(token);
        }

    };

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        twttr = new AsyncTwitterFactory().getInstance();
        twttr.setOAuthConsumer(UserTwitter.CONSUMER_KEY, UserTwitter.CONSUMER_SECRET);
        twttr.addListener(adapter);
        twttr.getOAuthRequestTokenAsync(CALLBACK_URL);
    }

    @Override
    protected void onNewIntent(Intent intent){
        super.onNewIntent(intent);
        Uri uri = intent.getData();
        if(uri != null && uri.toString().startsWith(CALLBACK_URL)){
            String verifier = uri.getQueryParameter("oauth_verifier");
            if(verifier != null){
                twttr.getOAuthAccessTokenAsync(requestToken, verifier);
            } else {
                finish();
                UserTwitter.instance.onLoginCancel();
            }
        } else {
            // other
            finish();
        }
    }

    @Override
    public void onBackPressed(){
    }

}
