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

#import "AdsAmoad.h"
#import "AMoAdSDK.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAmoad

@synthesize debug = __debug;

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    [AMoAdSDK sendUUID];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    NSString* mode = [info objectForKey:@"mode"];
    NSString* triggerID = [info objectForKey:@"triggerID"];
    NSString* hasAdsAppvadorInterstitial = [info objectForKey:@"hasAdsAppvadorInterstitial"];
    
    if ([mode isEqualToString:@"request"]) {
        [AMoAdSDK sendTriggerID:triggerID callbackBlock:^(NSInteger sts, NSString *url, NSInteger width, NSInteger height) {
            if (sts) {
                OUTPUT_LOG(@"Amoad sendTriggerID erros");
            } else {
                [AdsWrapper onAdsResult:self withRet:kAdsReceived withMsg:url];
            }
        }];
    } else {
        if ([hasAdsAppvadorInterstitial isEqualToString:@"YES"]) {
            //下の方法だとウォール表示後にAppVadorのバナー広告がタップできなくなるので、ルートビューコントローラーで表示
            [AMoAdSDK showAppliPromotionWall:[AdsWrapper getCurrentRootViewController]];
        } else {
            //Felloと同じ階層にビューコントローラーを生成
            UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
            UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
            if (topWindow.windowLevel != UIWindowLevelNormal)
            {
                NSArray *windows = [[UIApplication sharedApplication] windows];
                for(topWindow in windows)
                {
                    if (topWindow.windowLevel == UIWindowLevelNormal)
                    break;
                }
            }
            UIView *rootView = [[topWindow subviews] objectAtIndex:0];
            [rootView addSubview:viewController.view];
            
            [AMoAdSDK showAppliPromotionWall:viewController];
        }
    }
}

- (void) hideAds: (NSMutableDictionary*) info
{
    OUTPUT_LOG(@"Amoad not support hideAds!");
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Amoad not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Amoad not support spend points!");
}

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
}

- (NSString*) getSDKVersion
{
    return @"20140526";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (NSNumber*) isFirstTimeInToday
{
    return [NSNumber numberWithBool:[AMoAdSDK isFirstTimeInToday]];
}

@end
