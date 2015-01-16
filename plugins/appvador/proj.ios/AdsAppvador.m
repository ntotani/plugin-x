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

#import "AdsAppvador.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAppvador
{
    AvAdView* avAdView;
}

@synthesize debug = __debug;

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    NSString* bannerAppId = (NSString*) [devInfo objectForKey:@"AppvadorBannerID"];
    UIViewController* rootViewController = [AdsWrapper getCurrentRootViewController];
    UIView* rootView = rootViewController.view;
    CGSize screenSize = rootView.frame.size;
    avAdView = [[AvAdView alloc] initWithFrame:CGRectMake(0, screenSize.height-kBannerHeight, kBannerWidth, kBannerHeight) applicationId:bannerAppId];
    avAdView.rootViewController = rootViewController;
    avAdView.delegate = self;
    [avAdView isTest:self.debug];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    if (avAdView) {
        [[AdsWrapper getCurrentRootViewController].view addSubview:avAdView];
        [avAdView adStart];
    } else {
        [AdsWrapper onAdsResult:self withRet:kUnknownError withMsg:@"banner"];
    }
}

- (void) hideAds: (NSMutableDictionary*) info
{
    if ([avAdView superview]) {
        [avAdView removeFromSuperview];
    }
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Appvador not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Appvador not support spend points!");
}

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
}

- (NSString*) getSDKVersion
{
    return @"1.2.6";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

//バナータップ時
- (void)avAdDidTap:(AvAdView*)avadview
{
    OUTPUT_LOG(@"AdsAppvador:avAdDidTap!");
}

//バナー広告ページが表示された時
- (void)avAdDidOpenFullMovieView:(AvAdView*)avadview
{
    OUTPUT_LOG(@"AdsAppvador:avAdDidOpenFullMovieView!");
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"banner"];
}

//バナー広告ページを閉じたとき
- (void)avAdDidCloseFullMovieView:(AvAdView*)avadview
{
    OUTPUT_LOG(@"AdsAppvador:avAdDidCloseFullMovieView!");
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"banner"];
}

//バナー広告読み込み完了時
- (void)avAdDidFinishedLoad:(AvAdView*)avadview
{
    OUTPUT_LOG(@"AdsAppvador:avAdDidFinishedLoad!");
}

//バナー広告読み込み失敗時
- (void)avAdDidFailToReceiveAd:(AvAdView*)avadview
{
    OUTPUT_LOG(@"AdsAppvador:avAdDidFailToReceiveAd!");
    //viewの削除
    if (avAdView) {
        [avAdView remove];
        avAdView = nil;
    }
    [AdsWrapper onAdsResult:self withRet:kUnknownError withMsg:@"banner"];
}

@end
