//
//  AvAdView.h
//
//  Created by AppVador Inc.
//  Copyright (c) 2014年 AppVador Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol AvAdViewDelegate;

/**
 * 動画再生をView
 */
@interface AvAdView : UIView

extern const float kBannerWidth;
extern const float kBannerHeight;
extern const float kIconWidth;
extern const float kIconHeight;

@property (nonatomic) UIViewController * rootViewController;

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *label;

@property (nonatomic,weak) id<AvAdViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame applicationId:(NSString*)appid;

-(void)adStart;

-(void)remove;

-(void)isTest:(BOOL)test;

-(void)allowsBackgroundBGM:(BOOL)allow;

@end


@protocol AvAdViewDelegate <NSObject>

//広告ページが表示された際に呼ばれます。
-(void)avAdDidOpenFullMovieView:(AvAdView*)avadview;

//広告ページが閉じた際に呼ばれます。
//BGMのあるアプリケーションはここでBGMの再開処理をしてください。
-(void)avAdDidCloseFullMovieView:(AvAdView*)avadview;

@optional
//広告の読み込みに成功の際に呼ばれます。
-(void)avAdDidFinishedLoad:(AvAdView*)avadview;

//実装は必須ではありませんが、広告が取得出来なかった際にアドネットワークなどの利用をお勧めします。
-(void)avAdDidFailToReceiveAd:(AvAdView*)avadview;

//バナータップ時に呼ばれます。
-(void)avAdDidTap:(AvAdView*)avadview;

@end