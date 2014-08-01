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

#import "ShareLine.h"
#import "ShareWrapper.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation ShareLine

@synthesize mShareInfo;
@synthesize debug = __debug;

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
}

- (void) share: (NSMutableDictionary*) shareInfo
{
    self.mShareInfo = shareInfo;
    //NSString* text = [NSString stringWithFormat:@"%@", [mShareInfo objectForKey:@"SharedText"]];
    NSString* imgPath = [mShareInfo objectForKey:@"SharedImagePath"];
    if (imgPath) {
        UIPasteboard* pb = [UIPasteboard generalPasteboard];
        [pb setData:UIImagePNGRepresentation([UIImage imageWithContentsOfFile:imgPath]) forPasteboardType:@"public.png"];
        NSString *urlString = [NSString stringWithFormat:@"line://msg/image/%@", pb.name];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) setDebugMode: (BOOL) debug
{
    self.debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"0";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (void) saveImageToGallery: (NSMutableDictionary*) params
{
    NSString* imgPath = [params objectForKey:@"imagePath"];
    
    //iOS6以上ではフォトアルバムに画像を保存する時アクセス許可が必要なのでチェック処理
    BOOL isAuthorization = YES;
    NSArray  *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
    NSInteger iOsVersionMajor  = [[aOsVersions objectAtIndex:0] intValue];
    if (iOsVersionMajor >= 6)
    {
        //このアプリの写真への認証状態を取得する
        isAuthorization = NO;
        switch ([ALAssetsLibrary authorizationStatus])
        {
            case ALAuthorizationStatusNotDetermined:
            case ALAuthorizationStatusAuthorized:
            {
                //写真へのアクセスを許可するか選択されていない
                //写真へのアクセスが許可されている
                isAuthorization = YES;
                break;
            }
            case ALAuthorizationStatusRestricted:
            {
                //設定 > 一般 > 機能制限で利用が制限されている
                isAuthorization = NO;
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case ALAuthorizationStatusDenied:
            {
                //設定 > プライバシー > 写真で利用が制限されている
                isAuthorization = NO;
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"写真へのアクセスが許可されていません。\n設定 > プライバシー > 写真で許可してください。"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            default:
                break;
        }
    }
    
    if ( isAuthorization && imgPath ) {
        UIPasteboard* pb = [UIPasteboard generalPasteboard];
        [pb setData:UIImagePNGRepresentation([UIImage imageWithContentsOfFile:imgPath]) forPasteboardType:@"shobon_screenshot.png"];
        
        ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary new];
        [assetsLibrary
         writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation([UIImage imageWithContentsOfFile:imgPath])
         metadata:nil
         completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"エラー"
                                          message:@"写真への保存に失敗しました。"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@""
                                          message:@"保存しました。"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

@end
