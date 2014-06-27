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

#import <MrdIconSDK/MrdIconSDK.h>
#import "AdsAsta.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAsta {
    MrdIconLoader* iconLoader;
}

@synthesize debug = __debug;

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    NSString* astaId = [devInfo objectForKey:@"AstaID"];
    int iconCount = [[devInfo objectForKey:@"iconCount"] integerValue];

    UIView* root = [AdsWrapper getCurrentRootViewController].view;
    CGSize screenSize = root.frame.size;
    CGSize iconSize = CGSizeMake(50, 50);
    CGFloat viewWidth = iconSize.width;
    float iconMargin = (screenSize.width - viewWidth * iconCount) / (iconCount + 1);
    float iconY = screenSize.height - iconSize.height - 3.0f;
    iconLoader = [[MrdIconLoader alloc] init];
    for (int i = 0; i < iconCount; i++) {
        CGRect frame;
        frame.origin = CGPointMake(iconMargin * (i + 1) + viewWidth * i, iconY);
        frame.size = iconSize;
        MrdIconCell* iconCell = [[[MrdIconCell alloc] initWithFrame:frame] autorelease];
        iconCell.iconFrame = CGRectMake(0, 0, iconSize.width - 2, iconSize.height - 2);
        iconCell.titleFrame = CGRectNull;
        iconCell.hidden = YES;
        [iconLoader addIconCell:iconCell];
        [root addSubview:iconCell];
    }
    [iconLoader startLoadWithMediaCode:astaId];
}

- (void) dealloc
{
    if (iconLoader != nil) {
        [iconLoader release];
        iconLoader = nil;
    }
    [super dealloc];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    for (MrdIconCell* cell in [iconLoader iconCells]) {
        cell.hidden = NO;
    }
}

- (void) hideAds: (NSMutableDictionary*) info
{
    for (MrdIconCell* cell in [iconLoader iconCells]) {
        cell.hidden = YES;
    }
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Asta not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Asta not support spend points!");
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

@end
