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

#import "ShareTwitter.h"
#import "ShareWrapper.h"
#import "UserWrapper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation ShareTwitter {
    ACAccountStore* accountStore;
    ACAccountType* accountType;
}

@synthesize mShareInfo;
@synthesize debug = __debug;

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
}

- (void) share: (NSMutableDictionary*) shareInfo
{
    self.mShareInfo = shareInfo;
    SLComposeViewController *cvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
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

- (void) login
{
    accountStore = [[ACAccountStore alloc] init];
    accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (error) {
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:[error localizedDescription]];
            return;
        }
        NSArray* accounts = [accountStore accountsWithAccountType:accountType];
        if ([accounts count] == 0) {
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"no_accounts"];
            return;
        }
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@""];
    }];
}

- (void) fetchFriends:(NSString*)cursor
{
    ACAccount* account = [accountStore accountsWithAccountType:accountType].firstObject;
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
    NSDictionary* params = @{@"screen_name" : [account username],
                             @"cursor" : cursor,
                             @"count" : @"200",
                             @"skip_status" : @"t",
                             @"include_user_entities" : @"t"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    request.account = account;
    [request performRequestWithHandler:^(NSData* responseData,
                                         NSHTTPURLResponse* urlResponse,
                                         NSError* error) {
        if (error) {
            OUTPUT_LOG(@"%@, %@", urlResponse, error);
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"unknown\"}"];
            return;
        }
        if (200 <= urlResponse.statusCode && urlResponse.statusCode < 300) {
            NSString* json = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:json];
            NSError* e = nil;
            NSDictionary* jsonData = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingAllowFragments error:&e];
            if (e) {
                OUTPUT_LOG(@"%@", e);
                [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"invalid\"}"];
                return;
            }
            /*
             if (jsonData.count > 0) {
             NSLog(@"%@", [jsonData.firstObject objectForKey:@"next_cursor"]);
             NSLog(@"%@", jsonData);
             }
             */
            NSLog(@"%@", [jsonData objectForKey:@"next_cursor_str"]);
            NSArray* users = [jsonData objectForKey:@"users"];
            for (NSDictionary* user in users) {
                NSLog(@"%@", [user objectForKey:@"screen_name"]);
            }
        } else {
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"network\"}"];
        }
    }];
}

- (void) logout
{
}

- (BOOL) isLogined
{
    if (accountStore == nil) {
        return NO;
    }
    return [accountStore accountsWithAccountType:accountType].count > 0;
}

- (NSString*) getSessionID
{
    return @"";
}

- (void) setDebugMode: (NSNumber*) debug
{
    self.debug = [debug boolValue];
}

- (NSString*) getSDKVersion
{
    return @"20130607";
}

- (NSString*) getPluginVersion
{
    return @"0.2.0";
}

- (UIViewController *)getCurrentRootViewController {

    UIViewController *result = nil;

    // Try to find the root view controller programmically

    // Find the top window (that is not an alert view or other window)
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
    id nextResponder = [rootView nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        result = topWindow.rootViewController;
    else
        NSAssert(NO, @"Could not find a root view controller.");

    return result;
}

@end
