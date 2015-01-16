//
//  InterstitialAd.h
//  AppVador
//
//  Created by AppVador Inc.
//  Copyright (c) 2014年 AppVador Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AvInterstitialAdViewDelegate;

@interface InterstitialAd : NSObject

+ (InterstitialAd*)initializeWithAppId:(NSString*)appId;
+ (void)showInterstitial;
+ (void)setDelegate:(id<AvInterstitialAdViewDelegate>)delegate;

//@property (nonatomic,weak) id<AvInterstitialAdViewDelegate> delegate;

@end

@protocol AvInterstitialAdViewDelegate <NSObject>

//広告が表示された際に呼ばれます。
-(void)avInterstitialAdDidOpen;

//広告が閉じた際に呼ばれます。
-(void)avInterstitialAdDidClose;

@optional
//実装は必須ではありませんが、広告が取得出来なかった際にアドネットワークなどの利用をお勧めします。
-(void)avInterstitialAdDidFailToReceiveAd;

@end
