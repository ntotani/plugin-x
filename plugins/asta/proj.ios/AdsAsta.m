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

#import "AdsAsta.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAsta {
    MrdIconLoader* iconLoader;
    int lastIconCount;
}

@synthesize debug = __debug;
@synthesize astaId;

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    self.astaId = [devInfo objectForKey:@"AstaID"];
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
    int iconCount = [[info objectForKey:@"iconCount"] integerValue];
    int iconPerLine = [[info objectForKey:@"iconPerLine"] integerValue];
    float posY = [[info objectForKey:@"posY"] floatValue];
    
    UIView* root = [AdsWrapper getCurrentRootViewController].view;
    CGSize screenSize = root.frame.size;
    CGSize iconSize = CGSizeMake(50, 50);
    CGFloat viewWidth = iconSize.width;
    float iconMargin = (screenSize.width - viewWidth * iconPerLine) / (iconPerLine + 1);
    float iconY = screenSize.height * posY;
    iconLoader = [[MrdIconLoader alloc] init];
    
    int idx = 0;
    for (int i = 0; i < iconCount; i++) {
        
        if (i > 0 && i % iconPerLine == 0) {
            //行替え
            idx = 0;
            iconY += iconSize.height + iconMargin;
        }
        
        CGRect frame;
        frame.origin = CGPointMake(iconMargin * (idx + 1) + viewWidth * idx, iconY);
        frame.size = iconSize;
        MrdIconCell* iconCell = [[[MrdIconCell alloc] initWithFrame:frame] autorelease];
        iconCell.iconFrame = CGRectMake(0, 0, iconSize.width - 2, iconSize.height - 2);
        iconCell.titleFrame = CGRectNull;
        iconCell.hidden = YES;
        [iconLoader addIconCell:iconCell];
        [root addSubview:iconCell];
        
        ++idx;
    }
    iconLoader.delegate = self;
    [iconLoader startLoadWithMediaCode:self.astaId];
    
    for (MrdIconCell* cell in [iconLoader iconCells]) {
        cell.hidden = NO;
    }
    lastIconCount = iconCount;
}

- (void) hideAds: (NSMutableDictionary*) info
{
    for (MrdIconCell* cell in [iconLoader iconCells]) {
        [cell removeFromSuperview];
    }
    [iconLoader stop];
    [iconLoader release];
    iconLoader = nil;
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

// Called after the loader changes cells with valid contents.
- (void)loader:(MrdIconLoader*)loader didReceiveContentForCells:(NSArray*)cells
{
}

// Called when the loader failed to get contents for cells.
// This may be called after -loader:didReceiveContentForCells: when
//  found contents is less than count of added cells.
- (void)loader:(MrdIconLoader*)loader didFailToLoadContentForCells:(NSArray*)cells
{
    [AdsWrapper onAdsResult:self withRet:kNetworkError withMsg:@"asta"];
}

// Called as soon as the view was tapped.
// You can prevent opening browser with returning NO.
// Also you might do something before your app will be suspended.
// (e.g.; pause game, save user`s data, logging, etc.)
// When YES is returned or delegate does not implement this, the app will open url.
- (BOOL)loader:(MrdIconLoader*)loader willHandleTapOnCell:(MrdIconCell*)aCell
{
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:[NSString stringWithFormat:@"asta%d", lastIconCount]];
    return YES;
}

// Called before app will open url
- (void)loader:(MrdIconLoader*)loader willOpenURL:(NSURL*)url cell:(MrdIconCell*)aCell
{
}

@end
