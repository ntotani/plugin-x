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

#import "AdsAid.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAid
{
    NSString* AppId;
    NSString* AppIdCp;
    NSString* AppIdInterstitial;
}

@synthesize debug = __debug;

#pragma mark InterfaceAds impl

//コールバック
- (void)aidCallback:(NSString*)msg code:(int)code;
{
    OUTPUT_LOG(@"AdsAid:aidCallback! code=%d", code);
    [AdsWrapper onAdsResult:self withRet:code withMsg:msg];
}

- (void)showDialogAfterLoad: (NSTimer*)timer
{
    NSDictionary* userInfo = [timer userInfo];
    AidAdAgent* agent = [userInfo objectForKey:@"agent"];
    
    do {
        if ([agent hasLoadedContent]) {
            // 広告コンテンツは読み込み済み
            OUTPUT_LOG(@"AidAd basic content is ready");
            break;
        }
        
        NSDate* started = [userInfo objectForKey:@"started"];
        NSTimeInterval delay = 0 - [started timeIntervalSinceNow];
        if ( delay > 10) {
            // 10秒経っていたら広告が間に合わないとしてあきらめる
            OUTPUT_LOG(@"AidAd content is not available");
            break;
        }
        
        // 次のタイマーによる呼び出しを待つ
        return;
        
    } while (0);
    
    //広告ダイアログを表示
    OUTPUT_LOG(@"AdsAid aidAgent showDialog");
    [agent showDialog];
    [timer invalidate];
}

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    OUTPUT_LOG(@"AdsAid configDeveloperInfo!");
    AppId = (NSString*) [devInfo objectForKey:@"AidID"];
    AppIdCp = (NSString*) [devInfo objectForKey:@"AidIDCp"];
    AppIdInterstitial = (NSString*) [devInfo objectForKey:@"AidIDInterstitial"];
    
    if (![AppId isEqualToString:@""]) {
        //広告の取得を開始します
        OUTPUT_LOG(@"AdsAid gen aidAgent");
        [[AidAd agentForMedia:AppId] startLoading];
    }
    if (![AppIdCp isEqualToString:@""]) {
        //自社広告の取得を開始します
        OUTPUT_LOG(@"AdsAid gen aidAgentCp");
        [[AidAd agentForMedia:AppIdCp] startLoading];
        [[AidAd agentForMedia:AppIdCp] setDelegate:self];
    }
    if (![AppIdInterstitial isEqualToString:@""]) {
        OUTPUT_LOG(@"AdsAid gen aidAgent");
        [[AidAd agentForMedia:AppIdInterstitial] setPreferredCreativeStyle:kAidAdCreativeStyle_POPUP_IMAGE];
        [[AidAd agentForMedia:AppIdInterstitial] startLoading];
    }
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    OUTPUT_LOG(@"AdsAid showAds!");
    NSString* mode = (NSString*)[info objectForKey:@"mode"];
    
    AidAdAgent* agent;
    if ([mode isEqualToString:@"cp"]) {
        agent = [AidAd agentForMedia:AppIdCp];
    } else if ([mode isEqualToString:@"interstitial"]) {
        agent = [AidAd agentForMedia:AppIdInterstitial];
    } else {
        agent = [AidAd agentForMedia:AppId];
    }
    
    if (agent)
    {
        if ([agent hasLoadedContent]) {
            [agent showDialog];
        } else {
            // 取得完了した事を定期的にチェックさせるタイマー
            NSDictionary* userInfo = @{@"agent":agent, @"started":[NSDate date]};
            [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(showDialogAfterLoad:)
                                           userInfo:userInfo
                                            repeats:YES];
        }
    }
}

- (void) hideAds: (NSMutableDictionary*) info
{
    OUTPUT_LOG(@"Aid not support hideAds!");
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Aid not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Aid not support spend points!");
}

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
}

- (NSString*) getSDKVersion
{
    return @"1.2.1";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (void)adAgentDidOpenDialog:(AidAdAgent*)agent
{
    OUTPUT_LOG(@"AdsAid adAgentDidOpenDialog!");
}

- (void)adAgentDidCloseDialog:(AidAdAgent*)agent
{
    OUTPUT_LOG(@"AdsAid adAgentDidCloseDialog!");
}

- (void)adAgentDidDetectCloseButtonWasTapped:(AidAdAgent*)agent
{
    OUTPUT_LOG(@"AdsAid adAgentDidDetectCloseButtonWasTapped!");
    [self aidCallback:@"tap_btn_close" code:kAdsReceived];
}

- (void)adAgentDidDetectDetailButtonWasTapped:(AidAdAgent*)agent
{
    OUTPUT_LOG(@"AdsAid adAgentDidDetectDetailButtonWasTapped!");
    [self aidCallback:@"tap_btn_detail" code:kAdsReceived];
}

@end
