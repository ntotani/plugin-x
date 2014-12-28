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
{
    UIImageView *dollView;
    id onShutter;
    id onRetake;
}

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

- (UIImage*)convertImg:(NSString*)path with:(int)idx
{
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:path, idx]];
    CGRect clip = CGRectMake(0, 0, img.size.width, img.size.height * 2 / 3);
    CGImageRef trim = CGImageCreateWithImageInRect(img.CGImage, clip);
    img = [UIImage imageWithCGImage:trim];
    CGImageRelease(trim);
    return img;
}

- (void) showCamera:(NSMutableDictionary*)params
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [AdsWrapper onAdsResult:self withRet:1 withMsg:@"no_camera"];
        return;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(size.width / 4, size.height / 5, size.width, size.height * 2 / 3);
    dollView = [[UIImageView alloc] initWithFrame:frame];
    dollView.image = [self convertImg:params[@"path"] with:0];
    NSMutableArray *imgs = [NSMutableArray array];
    for (int i = 1; i < [params[@"frames"] intValue]; i++) {
        [imgs addObject:[self convertImg:params[@"path"] with:i]];
    }
    dollView.animationImages = imgs;
    dollView.animationDuration = [params[@"frames"] intValue] / [params[@"fps"] intValue];
    dollView.animationRepeatCount = 0;
    [dollView startAnimating];
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    pc.sourceType = UIImagePickerControllerSourceTypeCamera;
    pc.delegate = self;
    pc.cameraOverlayView = dollView;
    [[AdsWrapper getCurrentRootViewController] presentViewController:pc animated:YES completion:nil];
    onShutter = [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIImagePickerControllerUserDidCaptureItem" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [dollView stopAnimating];
    }];
    onRetake = [[NSNotificationCenter defaultCenter] addObserverForName:@"_UIImagePickerControllerUserDidRejectItem" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [dollView startAnimating];
    }];
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
    [[NSNotificationCenter defaultCenter] removeObserver:onShutter];
    [[NSNotificationCenter defaultCenter] removeObserver:onRetake];
    [[AdsWrapper getCurrentRootViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [AdsWrapper onAdsResult:self withRet:1 withMsg:@"cancel"];
    [[NSNotificationCenter defaultCenter] removeObserver:onShutter];
    [[NSNotificationCenter defaultCenter] removeObserver:onRetake];
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
