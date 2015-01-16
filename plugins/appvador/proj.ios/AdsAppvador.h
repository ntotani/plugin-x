/****************************************************************************
 Copyright (c) 2013 cocos2d-x.org
 
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

#import <Foundation/Foundation.h>
#import "InterfaceAds.h"
#import <AppVador/AvAdView.h>
#import <AppVador/InterstitialAd.h>

@interface AdsAppvador : NSObject <InterfaceAds, AvAdViewDelegate, AvInterstitialAdViewDelegate>
{
}

@property BOOL debug;

//コールバック
- (void)appVadorCallback:(NSString*)msg code:(int)code;

/**
 interfaces from InterfaceAds
 */
- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo;
- (void) showAds: (NSMutableDictionary*) info position:(int) pos;
- (void) hideAds: (NSMutableDictionary*) info;
- (void) queryPoints;
- (void) spendPoints: (int) points;
- (void) setDebugMode: (NSNumber*) isDebugMode;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

//バナータップ時
- (void)avAdDidTap:(AvAdView*)avadview;

//バナー広告ページが表示された時
- (void)avAdDidOpenFullMovieView:(AvAdView*)avadview;

//バナー広告ページを閉じたとき
- (void)avAdDidCloseFullMovieView:(AvAdView*)avadview;

//バナー広告読み込み完了時
- (void)avAdDidFinishedLoad:(AvAdView*)avadview;

//バナー広告読み込み失敗時
- (void)avAdDidFailToReceiveAd:(AvAdView*)avadview;

//インタースティシャル広告開始時
- (void)avInterstitialAdDidOpen;

//インタースティシャル広告終了時
- (void)avInterstitialAdDidClose;

//インタースティシャル広告失敗時
- (void)avInterstitialAdDidFailToReceiveAd;

@end
