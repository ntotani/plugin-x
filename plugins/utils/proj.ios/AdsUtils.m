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

#import "AdsUtils.h"
#import "AdsWrapper.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsUtils

@synthesize debug = __debug;

#pragma mark InterfaceAds impl

- (void)saveImage:(NSString*)path
{
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    [lib writeImageToSavedPhotosAlbum:img.CGImage orientation:(ALAssetOrientation)img.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        NSString *title = @"";
        NSString *message = @"保存しました";
        if (error) {
            title = @"エラー";
            message = @"写真へのアクセスが許可されていません。\n設定からアクセスを許可してください。";
        }
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:title
                                  message:message
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo{}
- (void) showAds: (NSMutableDictionary*) info position:(int) pos{}
- (void) hideAds: (NSMutableDictionary*) info{}
- (void) queryPoints{}
- (void) spendPoints: (int) points{}

- (void) setDebugMode: (BOOL) isDebugMode
{
    self.debug = isDebugMode;
}

- (NSString*) getSDKVersion
{
    return @"0.0.0";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

@end
