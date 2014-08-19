#import "UserRkyun.h"
#import "UserWrapper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "XMLReader.h"

#define OUTPUT_LOG(...)    if (_debug) NSLog(__VA_ARGS__);

@implementation UserRkyun {
    BOOL _debug;
    ACAccount* _account;
    NSString* _yahooAppId;
}

- (void)dealloc
{
    if (_account) {
        [_account release];
        _account = nil;
    }
    if (_yahooAppId) {
        [_yahooAppId release];
        _yahooAppId = nil;
    }
    [super dealloc];
}

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    _yahooAppId = cpInfo[@"YahooAppID"];
    [_yahooAppId retain];
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
        [_account retain];
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@""];
    }];
}

-(id)fetchSync:(NSString*)api withParams:(NSDictionary*)params withEncode:(BOOL)encode
{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/%@.json", api]];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    request.account = _account;
    NSHTTPURLResponse* urlResponse = nil;
    NSError* error = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:[request preparedURLRequest] returningResponse:&urlResponse error:&error];
    if (error) {
        OUTPUT_LOG(@"%@, %@", urlResponse, error);
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"unknown\"}"];
        return nil;
    }
    if (200 <= urlResponse.statusCode && urlResponse.statusCode < 300) {
        if (encode) {
            return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        }
        NSError* err = nil;
        id jsonData = [NSJSONSerialization
                       JSONObjectWithData:responseData
                       options:NSJSONReadingAllowFragments
                       error:&err];
        if (err) {
            OUTPUT_LOG(@"%@", err);
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"invalid\"}"];
            return nil;
        }
        return jsonData;
    } else {
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"network\"}"];
    }
    return nil;
}

- (void) fetchFriends:(NSString*)cursor
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* params = @{@"screen_name" : [_account username],
                                 @"cursor" : cursor,
                                 @"count" : @"200",
                                 @"skip_status" : @"t",
                                 @"include_user_entities" : @"t"};
        NSString* friendsList = [self fetchSync:@"friends/list" withParams:params withEncode:YES];
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:friendsList];
    });
}

- (void) process:(NSString*)heroine
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary* friendScore = [@{} mutableCopy];
        BOOL (^scoreForId)(NSString*, void(^)(NSNumber*)) = ^BOOL(NSString* screenName, void(^callback)(NSNumber*)) {
            NSString* cursor = @"-1";
            while (![cursor isEqualToString:@"0"]) {
                NSDictionary* jsonData = [self fetchIds:screenName withCursor:cursor];
                if (!jsonData) {
                    return YES;
                }
                for (NSNumber* e in jsonData[@"ids"]) {
                    callback(e);
                }
                cursor = jsonData[@"next_cursor_str"];
            }
            return NO;
        };
        if (scoreForId(_account.username, ^(NSNumber* e) {
            friendScore[e] = @0;
        })) { return; };
        if (scoreForId(heroine, ^(NSNumber* e) {
            if (friendScore[e]) {
                friendScore[e] = @10;
            }
        })) { return; };

        // score reply
        NSArray* playerTimeline = [self fetchTimeline:_account.username];
        if (!playerTimeline) {
            return;
        }
        for (NSDictionary* e in playerTimeline) {
            NSNumber* reply = e[@"in_reply_to_user_id"];
            if (reply && friendScore[reply]) {
                friendScore[reply] = @([friendScore[reply] intValue] + 1);
            }
        }

        // rank friends
        NSMutableArray* friends = [@[] mutableCopy];
        for (NSNumber* e in friendScore) {
            [friends addObject:@{@"id": e, @"score":friendScore[e]}];
        }
        [friends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber* a = obj1[@"score"];
            NSNumber* b = obj2[@"score"];
            return [b compare:a];
        }];

        // fetch timelines
        NSArray* heroineTimeline = [self fetchTimeline:heroine];
        if (!heroineTimeline) {
            return;
        }
        NSNumber* heroineId = @0;
        for (NSDictionary* e in heroineTimeline) {
            if (!e[@"retweeted"]) {
                heroineId = e[@"user"][@"id"];
                break;
            }
        }
        NSNumber* enemyId = @0;
        for (NSDictionary* e in friends) {
            if (![e[@"id"] isEqualToNumber:heroineId]) {
                enemyId = e[@"id"];
                break;
            }
        }

        NSArray* enemyTimeline = [self fetchTimelineById:enemyId];
        if (!enemyTimeline) {
            return;
        }

        NSMutableArray* allTexts = [@[] mutableCopy];
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"@[a-z0-9_]+" options:NSRegularExpressionCaseInsensitive error:nil];
        void (^addText)(NSArray*) = ^void(NSArray* timeline) {
            for (NSDictionary* e in timeline) {
                NSString* text = e[@"text"];
                if (![text hasPrefix:@"RT "]) {
                    [allTexts addObject:[regexp stringByReplacingMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length) withTemplate:@""]];
                }
            }
        };
        addText(playerTimeline);
        addText(heroineTimeline);
        addText(enemyTimeline);
        NSString* sentence = [allTexts componentsJoinedByString:@"。"];
        OUTPUT_LOG(@"%@", sentence);
        //NSArray* words = [self fetchNouns:sentence];
        NSArray* words = [self fetchKeyPhrase:sentence];
        for (NSString* e in words) {
            OUTPUT_LOG(@"%@", e);
        }
    });
}

-(id)fetchIds:(NSString*)screenName withCursor:(NSString*)cursor
{
    NSDictionary* params = @{@"screen_name":screenName, @"cursor":cursor, @"count":@"5000"};
    return [self fetchSync:@"friends/ids" withParams:params withEncode:NO];
}

-(id)fetchTimeline:(NSString*)screenName
{
    NSDictionary* params = @{@"screen_name":screenName, @"trim_user":@"t"};
    return [self fetchSync:@"statuses/user_timeline" withParams:params withEncode:NO];
}

-(id)fetchTimelineById:(NSNumber*)userId
{
    NSDictionary* params = @{@"user_id":[userId stringValue], @"trim_user":@"t"};
    return [self fetchSync:@"statuses/user_timeline" withParams:params withEncode:NO];
}

-(NSArray*)fetchKeyPhrase:(NSString*)sentence
{
    NSData* responseData = [self fetchWords:@"KeyphraseService/V1/extract" withSentence:sentence withParams:@{@"output": @"json"}];
    if (!responseData) {
        return nil;
    }
    NSError* err = nil;
    NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&err];
    if (err) {
        OUTPUT_LOG(@"%@", err);
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"invalid\"}"];
        return nil;
    }
    return [jsonData allKeys];
}

-(NSArray*)fetchNouns:(NSString*)sentence
{
    NSData* responseData = [self fetchWords:@"MAService/V1/parse" withSentence:sentence withParams:@{@"response": @"surface", @"filter": @"9"}];
    if (!responseData) {
        return nil;
    }
    NSError* err = nil;
    NSDictionary* xml = [XMLReader dictionaryForXMLData:responseData error:&err];
    NSMutableArray* wordList = [@[] mutableCopy];
    for (NSDictionary* e in xml[@"ResultSet"][@"ma_result"][@"word_list"][@"word"]) {
        [wordList addObject:e[@"surface"][@"text"]];
    }
    return wordList;
}

-(NSData*)fetchWords:(NSString*)api withSentence:(NSString*)sentence withParams:(NSDictionary*)params
{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://jlp.yahooapis.jp/%@", api]];
    NSMutableArray* paramArr = [@[[NSString stringWithFormat:@"appid=%@", _yahooAppId], [NSString stringWithFormat:@"sentence=%@", [sentence stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] mutableCopy];
    for (NSString* e in params) {
        [paramArr addObject:[NSString stringWithFormat:@"%@=%@", e, params[e]]];
    }
    NSString* param = [paramArr componentsJoinedByString:@"&"];
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    NSHTTPURLResponse* res = nil;
    NSError* err = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    if (err) {
        OUTPUT_LOG(@"%@", err);
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"unknown\"}"];
        return nil;
    }
    if (200 > res.statusCode || res.statusCode >= 300) {
        OUTPUT_LOG(@"%d", res.statusCode);
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"{\"error\":\"network\"}"];
        return nil;
    }
    return responseData;
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
