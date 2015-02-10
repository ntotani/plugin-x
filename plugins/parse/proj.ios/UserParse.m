#import "UserParse.h"
#import "UserWrapper.h"
#import "AdsWrapper.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);
#define LOVER_PROGRESS 100
#define TURNMIN_DEFAULT 180
#define TURNMIN_LOSS 10
#define TURNMIN_MIN 10

@implementation UserParse

@synthesize debug = __debug;
NSString *_fbUserID = @"";
NSString *_fbUserName = @"";

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
}

- (void) login
{
}

- (void) loginWithTwitter
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            OUTPUT_LOG(@"%@", [error userInfo][@"error"]);
            int code = 4;
            NSString *msg = @"unknown";
            if ([error code] == kPFErrorConnectionFailed) { code = 1; msg = @"network"; }
            else if ([error code] == kPFErrorInternalServer) { code = 2; msg = @"server"; }
            else if ([error code] == kPFErrorExceededQuota) { code = 3; msg = @"overquota"; }
            [UserWrapper onActionResult:self withRet:code withMsg:msg];
            return;
        }
        if (!user) {
            [UserWrapper onActionResult:self withRet:5 withMsg:@"cancel"];
        } else {
            [UserWrapper onActionResult:self withRet:0 withMsg:user.username];
        }
    }];
}

- (void) loginWithFacebook
{
    [PFFacebookUtils logInWithPermissions:@[@"read_stream"] block:^(PFUser *user, NSError *error) {
        if (error) {
            OUTPUT_LOG(@"%@", [error userInfo][@"error"]);
            int code = 4;
            NSString *msg = @"unknown";
            if ([error code] == kPFErrorConnectionFailed) { code = 1; msg = @"network"; }
            else if ([error code] == kPFErrorInternalServer) { code = 2; msg = @"server"; }
            else if ([error code] == kPFErrorExceededQuota) { code = 3; msg = @"overquota"; }
            [UserWrapper onActionResult:self withRet:code withMsg:msg];
            return;
        }
        if (!user) {
            [UserWrapper onActionResult:self withRet:5 withMsg:@"cancel"];
        } else {
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *fbUser, NSError *error) {
                _fbUserID = fbUser[@"id"];
                [_fbUserID retain];
                _fbUserName = fbUser[@"name"];
                [_fbUserName retain];
                [UserWrapper onActionResult:self withRet:0 withMsg:user.username];
            }];
        }
    }];
}

- (void) logout
{
    [PFUser logOut];
}

- (NSNumber*) isLoggedIn
{
    return [PFUser currentUser] == nil ? @0 : @1;
}

- (NSString*) getSessionID
{
    if ([PFUser currentUser]) {
        return [PFUser currentUser].username;
    }
    return nil;
}

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
}

- (NSString*) getSDKVersion
{
    return @"1.6.2";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (NSString*)getTwitterID
{
    return [PFTwitterUtils twitter].userId;
}

- (NSString*)getFacebookID
{
    return _fbUserID;
}

- (NSString*)twitterApi:(NSMutableDictionary*)params
{
    NSString* api = params[@"Param1"];
    params = params[@"Param2"];
    NSMutableArray* paramsArr = [NSMutableArray array];
    for (NSString* e in params) {
        [paramsArr addObject:[NSString stringWithFormat:@"%@=%@", e, params[e]]];
    }
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/%@.json?%@", api, [paramsArr componentsJoinedByString:@"&"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 5.0;
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError* error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost) {
            return @"network";
        }
        return [NSString stringWithFormat:@"{\"errors\":[{\"message\":\"%@\",\"code\":999}]}", [error localizedDescription]];
    }
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (void)cloudFunc:(NSMutableDictionary*)params
{
    NSString *name = params[@"Param1"];
    NSMutableDictionary *prms = params[@"Param2"];
    if (prms[@"twID"]) {
        prms[@"twID"] = @([prms[@"twID"] longLongValue]);
    }
    [PFCloud callFunctionInBackground:name withParameters:prms block:^(id object, NSError *error) {
        if (error || !object) {
            int code = 4;
            NSString *msg = @"unknown";
            if ([error code] == kPFErrorConnectionFailed) { code = 1; msg = @"network"; }
            else if ([error code] == kPFErrorInternalServer) { code = 2; msg = @"server"; }
            else if ([error code] == kPFErrorExceededQuota) { code = 3; msg = @"overquota"; }
            [UserWrapper onActionResult:self withRet:code withMsg:msg];
        } else {
            [UserWrapper onActionResult:self withRet:0 withMsg:object];
        }
    }];
}

@end
