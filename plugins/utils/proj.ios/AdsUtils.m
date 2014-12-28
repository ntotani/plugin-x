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

- (void)showDialog:(NSMutableDictionary*)params
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:params[@"title"] message:params[@"message"] preferredStyle:UIAlertControllerStyleAlert];
    if (params[@"cancel"]) {
        [ac addAction:[UIAlertAction actionWithTitle:params[@"cancel"] style:UIAlertActionStyleCancel handler:nil]];
    }
    if (params[@"ok"]) {
        [ac addAction:[UIAlertAction actionWithTitle:params[@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [AdsWrapper onAdsResult:self withRet:0 withMsg:@"ok"];
        }]];
    }
    if (params[@"red"]) {
        [ac addAction:[UIAlertAction actionWithTitle:params[@"red"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [AdsWrapper onAdsResult:self withRet:0 withMsg:@"red"];
        }]];
    }
    [[AdsWrapper getCurrentRootViewController] presentViewController:ac animated:YES completion:nil];
}

- (void) showCamera:(NSString*)path
{
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    pc.sourceType = UIImagePickerControllerSourceTypeCamera;
    pc.delegate = self;
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    CGRect clip = CGRectMake(0, 0, img.size.width, img.size.height * 2 / 3);
    CGImageRef trim = CGImageCreateWithImageInRect(img.CGImage, clip);
    img = [UIImage imageWithCGImage:trim];
    CGImageRelease(trim);
    CGRect s = [UIScreen mainScreen].bounds;
    UIImageView *iv = [[UIImageView alloc] initWithImage:img];
    iv.frame = CGRectMake(s.size.width / 4, s.size.height / 5, s.size.width, s.size.height * 2 / 3);
    pc.cameraOverlayView = iv;
    [[AdsWrapper getCurrentRootViewController] presentViewController:pc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/camera.png", paths[0]];
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImagePNGRepresentation(img);
    if ([data writeToFile:path atomically:YES]) {
        [AdsWrapper onAdsResult:self withRet:0 withMsg:path];
    } else {
        [AdsWrapper onAdsResult:self withRet:1 withMsg:path];
    }
    [[AdsWrapper getCurrentRootViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo{}
- (void) showAds: (NSMutableDictionary*) info position:(int) pos{}
- (void) hideAds: (NSMutableDictionary*) info{}
- (void) queryPoints{}
- (void) spendPoints: (int) points{}

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
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
