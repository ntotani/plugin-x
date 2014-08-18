#import "UserRkyun.h"
#import "UserWrapper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define OUTPUT_LOG(...)    if (_debug) NSLog(__VA_ARGS__);

@implementation UserRkyun {
    BOOL _debug;
    ACAccount* _account;
    NSMutableDictionary* _friendScore;
    NSMutableArray* _playerTimeline;
    NSMutableArray* _heroineTimeline;
    NSMutableArray* _enemyTimeline;
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
    _friendScore = [@{} mutableCopy];
    _playerTimeline = [@[] mutableCopy];
    _heroineTimeline = [@[] mutableCopy];
    _enemyTimeline = [@[] mutableCopy];
    [self fetchIds:_account.username
        withCursor:@"-1"
       withAccount:_account
       withHeroine:heroine];
}

- (void)fetchIds:(NSString*)screenName withCursor:(NSString*)cursor withAccount:(ACAccount*)account withHeroine:(NSString*)heroine
{
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];
    NSDictionary* params = @{@"screen_name":screenName, @"cursor":cursor, @"count":@"5000"};
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
            NSError* err = nil;
            NSDictionary* jsonData = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingAllowFragments error:&err];
            if (err) {
                OUTPUT_LOG(@"%@", err);
                [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"invalid\"}"];
                return;
            }
            BOOL isPlayer = ![screenName isEqualToString:heroine];
            if (isPlayer) {
                for (NSNumber* e in jsonData[@"ids"]) {
                    _friendScore[e] = @0;
                }
            } else {
                for (NSNumber* e in jsonData[@"ids"]) {
                    if (_friendScore[e]) {
                        _friendScore[e] = @10;
                    }
                }
            }
            NSString* nextCursor = jsonData[@"next_cursor_str"];
            if (![nextCursor isEqualToString:@"0"]) {
                [self fetchIds:screenName withCursor:nextCursor withAccount:account withHeroine:heroine];
            } else {
                if (isPlayer) {
                    [self fetchIds:heroine withCursor:@"-1" withAccount:account withHeroine:heroine];
                } else {
                    [self fetchPlayerTimeline:account];
                }
            }
        } else {
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"network\"}"];
        }
    }];
}

-(void)fetchPlayerTimeline:(ACAccount*)account
{
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    NSDictionary* params = @{@"screen_name":account.username, @"trim_user":@"t"};
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
            NSError* err = nil;
            NSArray* jsonData = [NSJSONSerialization
                                      JSONObjectWithData:responseData
                                      options:NSJSONReadingAllowFragments error:&err];
            for (NSDictionary* e in jsonData) {
                NSNumber* reply = e[@"in_reply_to_user_id"];
                if (reply && _friendScore[reply]) {
                    _friendScore[reply] = @([_friendScore[reply] intValue] + 1);
                }
                [_playerTimeline addObject:e[@"text"]];
            }
            NSMutableArray* friends = [@[] mutableCopy];
            for (NSNumber* e in _friendScore) {
                [friends addObject:@{@"id": e, @"score":_friendScore[e]}];
            }
            [friends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber* a = obj1[@"score"];
                NSNumber* b = obj2[@"score"];
                return [b compare:a];
            }];
            // next step
            OUTPUT_LOG(@"%@", friends);
        } else {
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"network\"}"];
        }
    }];
}

-(void)fetchHeroineTimeline:(NSString*)heroine withAccount:(ACAccount*)account
{
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    NSDictionary* params = @{@"screen_name":heroine, @"trim_user":@"t"};
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
            NSError* err = nil;
            NSArray* jsonData = [NSJSONSerialization
                                 JSONObjectWithData:responseData
                                 options:NSJSONReadingAllowFragments error:&err];
            for (NSDictionary* e in jsonData) {
                [_heroineTimeline addObject:e[@"text"]];
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
