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

#import "ShareFacebook.h"
#import "ShareWrapper.h"
#import <Social/Social.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation ShareFacebook

@synthesize mShareInfo;
@synthesize debug = __debug;

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
}

- (void) share: (NSMutableDictionary*) shareInfo
{
    self.mShareInfo = shareInfo;
    SLComposeViewController *cvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [cvc setInitialText:[NSString stringWithFormat:@"%@", [mShareInfo objectForKey:@"SharedText"]]];
    NSString* imgPath = [mShareInfo objectForKey:@"SharedImagePath"];
    if (imgPath) {
        [cvc addImage:[UIImage imageWithContentsOfFile:imgPath]];
    }
    [cvc setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch(result){
            case SLComposeViewControllerResultCancelled:
                [ShareWrapper onShareResult:self withRet:kShareCancel withMsg:@"Share Cancelled"];
                break;
            case SLComposeViewControllerResultDone:
                [ShareWrapper onShareResult:self withRet:kShareSuccess withMsg:@"Share Succeed"];
                break;
        }
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:cvc animated:YES completion:nil];
}

- (void) setDebugMode: (BOOL) debug
{
    self.debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"20140602";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

@end
