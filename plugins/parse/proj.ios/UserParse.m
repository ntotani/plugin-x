#import "UserParse.h"
#import "UserWrapper.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);
#define LOVER_PROGRESS 100
#define TURNMIN_DEFAULT 180
#define TURNMIN_LOSS 10
#define TURNMIN_MIN 10

@implementation UserParse

@synthesize debug = __debug;

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    [Parse setApplicationId:cpInfo[@"ApplicationID"] clientKey:cpInfo[@"ClientKey"]];
    NSString* twitterConsumerKey = cpInfo[@"TwitterConsumerKey"];
    NSString* twitterConsumerSecret = cpInfo[@"TwitterConsumerSecret"];
    if (twitterConsumerKey != nil && twitterConsumerSecret != nil) {
        [PFTwitterUtils initializeWithConsumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecret];
    }
}

- (void) login
{
    PFLogInViewController* vc = [[PFLogInViewController alloc] init];
    vc.fields = PFLogInFieldsDefault | PFLogInFieldsTwitter;
    vc.delegate = self;
    [[AdsWrapper getCurrentRootViewController] presentViewController:vc animated:YES completion:nil];
}

- (void) loginWithTwitter
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            OUTPUT_LOG(@"%@", [error userInfo][@"error"]);
            NSString *msg = @"unkown";
            if ([error code] == kPFErrorConnectionFailed) { msg = @"network"; }
            else if ([error code] == kPFErrorInternalServer) { msg = @"server"; }
            else if ([error code] == kPFErrorExceededQuota) { msg = @"overquota"; }
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:msg];
            return;
        }
        if (!user) {
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"cancel"];
        } else {
            [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:user.username];
        }
    }];
}

- (void) logout
{
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

- (void) setDebugMode: (BOOL) isDebugMode
{
    self.debug = isDebugMode;
}

- (NSString*) getSDKVersion
{
    return @"1.4.1";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:user.username];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:[error localizedDescription]];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"cancel"];
}

- (NSString*)getTwitterID
{
    return [PFTwitterUtils twitter].userId;
}

- (void)fetchHeroine:(NSString *)ids
{
    NSMutableArray *numIds = [@[] mutableCopy];
    for (NSString *e in [ids componentsSeparatedByString:@","]) {
        [numIds addObject:@([e longLongValue])];
    }
    [PFCloud callFunctionInBackground:@"heroines" withParameters:@{@"ids":numIds} block:^(id object, NSError *error) {
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:object];
    }];
}

- (void)fetchGainedHeroine
{
    [PFCloud callFunctionInBackground:@"heroines" withParameters:@{} block:^(id object, NSError *error) {
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:object];
    }];
}

- (void)dateHeroine:(NSString*)twID
{
    [PFCloud callFunctionInBackground:@"date" withParameters:@{@"twID":@([twID intValue])} block:^(id object, NSError *error) {
    }];
}

- (void)attack:(NSString*)twID
{
    [PFCloud callFunctionInBackground:@"attack" withParameters:@{@"twID":@([twID intValue])} block:^(id object, NSError *error) {
        NSString *msg = object;
        if (!object) {
            msg = @"ng";
        }
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:msg];
    }];
}

- (void)breakHeroine:(NSString*)twID
{
    [PFCloud callFunctionInBackground:@"break" withParameters:@{@"twID":@([twID intValue])} block:^(id object, NSError *error) {
    }];
}

- (void)reserve:(NSString*)twID
{
    [PFCloud callFunctionInBackground:@"reserve" withParameters:@{@"twID":@([twID intValue])} block:^(id object, NSError *error) {
    }];
}

- (void)touchHeroine:(NSString*)twID
{
    [PFCloud callFunctionInBackground:@"touch" withParameters:@{@"twID":@([twID intValue])} block:^(id object, NSError *error) {
    }];
}

- (NSString*)twitterApi:(NSMutableDictionary*)params
{
    NSString* api = params[@"Param1"];
    params = params[@"Param2"];
    NSMutableArray* paramsArr = [@[] mutableCopy];
    for (NSString* e in params) {
        [paramsArr addObject:[NSString stringWithFormat:@"%@=%@", e, params[e]]];
    }
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/%@.json?%@", api, [paramsArr componentsJoinedByString:@"&"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError* error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return [NSString stringWithFormat:@"{\"errors\":[{\"message\":\"%@\",\"code\":999}]}", [error localizedDescription]];
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
