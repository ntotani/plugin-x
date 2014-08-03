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

#import "AdsNend.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsNend

@synthesize debug = __debug;

- (void) dealloc
{
    if (self.bannerView != nil) {
        [self.bannerView setDelegate:nil];
        [self.bannerView release];
        self.bannerView = nil;
    }
    [super dealloc];
}

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    NSString* apiKey = (NSString*)[devInfo objectForKey:@"ApiKey"];
    NSString* spotId = (NSString*)[devInfo objectForKey:@"SpotId"];
    self.bannerView = [[NADView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self.bannerView setIsOutputLog:self.debug];
    [self.bannerView setNendID:apiKey spotID:spotId];
    [self.bannerView setDelegate:self];
    [self.bannerView load];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    [AdsWrapper addAdView:self.bannerView atPos:pos];
}

- (void) hideAds: (NSMutableDictionary*) info
{
    [self.bannerView removeFromSuperview];
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Nend not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Nend not support spend points!");
}

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
    if (self.bannerView) {
        [self.bannerView setIsOutputLog:self.debug];
    }
}

- (NSString*) getSDKVersion
{
    return @"2.4.1";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (void)nadViewDidFinishLoad:(NADView *)adView
{
}

- (void)nadViewDidClickAd:(NADView *)adView
{
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"nend"];
}

- (void)nadViewDidReceiveAd:(NADView *)adView
{
}

- (void)nadViewDidFailToReceiveAd:(NADView *)adView
{
}

@end
