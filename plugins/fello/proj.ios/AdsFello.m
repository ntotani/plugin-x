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

#import <FelloPush/KonectNotificationsAPI.h>
#import "AdsFello.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsFello

@synthesize debug = __debug;

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    NSString* appId = (NSString*) [devInfo objectForKey:@"FelloID"];
    [KonectNotificationsAPI initialize:self launchOptions:@{} appId:appId];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    [KonectNotificationsAPI beginInterstitial:nil];
}

- (void) hideAds: (NSMutableDictionary*) info
{
    OUTPUT_LOG(@"Fello not support hideAds!");
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Fello not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Fello not support spend points!");
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

- (void)onCompleteAdRequest:(NSString *)scene success:(BOOL)success
{
    if (success) {
        OUTPUT_LOG(@"Fello request success");
    } else {
        OUTPUT_LOG(@"Fello request failed");
    }
}

- (void)onCompleteAdRequest:(NSString *)scene reason:(NSString *)reason
{
    OUTPUT_LOG(@"Fello close: %@, %@", scene, reason);
}

- (void)onShowAd:(NSString *)scene
{
    OUTPUT_LOG(@"Fello open: %@", scene);
}

@end
