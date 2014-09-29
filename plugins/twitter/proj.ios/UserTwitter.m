#import "UserTwitter.h"
#import "UserWrapper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define OUTPUT_LOG(...)     if (_debug) NSLog(__VA_ARGS__);

@implementation UserTwitter
{
    BOOL _debug;
    ACAccount* _account;
}

- (void)dealloc
{
    if (_account) {
        [_account release];
        _account = nil;
    }
    [super dealloc];
}

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
}

- (void) login
{
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (error) {
            OUTPUT_LOG(@"login error: %@", [error localizedDescription]);
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:[error localizedDescription]];
            return;
        }
        if (!granted) {
            OUTPUT_LOG(@"login error: not granted");
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"not_granted"];
            return;
        }
        NSArray* accounts = [accountStore accountsWithAccountType:accountType];
        if ([accounts count] == 0) {
            OUTPUT_LOG(@"login error: no accounts");
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"no_accounts"];
            return;
        }
        _account = accounts.firstObject;
        [_account retain];
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:[_account username]];
    }];
}

- (void) logout
{
}

- (BOOL) isLogined
{
    return _account != nil;
}

- (NSString*) getSessionID
{
    return [_account valueForKeyPath:@"properties.user_id"];
}

- (void) setDebugMode: (BOOL) debug
{
    _debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"1.1";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

- (NSString*) api: (NSMutableDictionary*) params
{
    NSString *path = [params objectForKey:@"Param1"];
    NSString *method = [params objectForKey:@"Param2"];
    NSDictionary *param = [params objectForKey:@"Param3"];

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/%@.json", path]];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:[method isEqualToString:@"POST"] ? SLRequestMethodPOST : SLRequestMethodGET
                                                      URL:url
                                               parameters:param];
    request.account = _account;
    NSHTTPURLResponse* urlResponse = nil;
    NSError* error = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:[request preparedURLRequest] returningResponse:&urlResponse error:&error];
    if (error) {
        return [NSString stringWithFormat:@"{\"errors\":[{\"message\":\"%@\",\"code\":999}]}", [error localizedDescription]];
    }
    return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

@end
