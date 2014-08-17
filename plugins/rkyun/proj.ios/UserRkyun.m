#import "UserRkyun.h"
#import "UserWrapper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define OUTPUT_LOG(...)    if (_debug) NSLog(__VA_ARGS__);

@implementation UserRkyun {
    BOOL _debug;
    ACAccount* _account;
    NSString* _heroine;
    NSMutableDictionary* _friendScore;
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
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:[error localizedDescription]];
            return;
        }
        NSArray* accounts = [accountStore accountsWithAccountType:accountType];
        if ([accounts count] == 0) {
            [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"no_accounts"];
            return;
        }
        _account = accounts.firstObject;
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@""];
    }];
}

- (void) fetchFriends:(NSString*)cursor
{
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
    NSDictionary* params = @{@"screen_name" : [_account username],
                             @"cursor" : cursor,
                             @"count" : @"200",
                             @"skip_status" : @"t",
                             @"include_user_entities" : @"t"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    request.account = _account;
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
        } else {
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"network\"}"];
        }
    }];
}

- (void) process:(NSString*)heroine
{
    _heroine = heroine;
    _friendScore = [@{} mutableCopy];
    [self fetchIds:_account.username withCursor:@"-1"];
}

- (void)fetchIds:(NSString*)screenName withCursor:(NSString*)cursor
{
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];
    NSDictionary* params = @{@"screen_name":screenName, @"cursor":cursor, @"count":@"5000"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    request.account = _account;
    [request performRequestWithHandler:^(NSData* responseData,
                                         NSHTTPURLResponse* urlResponse,
                                         NSError* error) {
        if (error) {
            OUTPUT_LOG(@"%@, %@", urlResponse, error);
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"unknown\"}"];
            return;
        }
        if (200 <= urlResponse.statusCode && urlResponse.statusCode < 300) {
            NSError* err = nil;
            NSDictionary* jsonData = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingAllowFragments error:&err];
            if (err) {
                OUTPUT_LOG(@"%@", err);
                [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"invalid\"}"];
                return;
            }
            BOOL isPlayer = ![screenName isEqualToString:_heroine];
            if (isPlayer) {
                for (NSNumber* e in jsonData[@"ids"]) {
                    _friendScore[e] = @0;
                }
            } else {
                for (NSNumber* e in jsonData[@"ids"]) {
                    if (_friendScore[e]) {
                        _friendScore[e] = @1;
                    }
                }
            }
            NSString* nextCursor = jsonData[@"next_cursor_str"];
            if (![nextCursor isEqualToString:@"0"]) {
                [self fetchIds:screenName withCursor:nextCursor];
            } else {
                if (isPlayer) {
                    [self fetchIds:_heroine withCursor:@"-1"];
                } else {
                    // next step
                    OUTPUT_LOG(@"%@", _friendScore);
                }
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
    return _account == nil;
}

- (NSString*) getSessionID
{
    return @"";
}

- (void) setDebugMode:(BOOL)debug
{
    _debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"1";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

@end
