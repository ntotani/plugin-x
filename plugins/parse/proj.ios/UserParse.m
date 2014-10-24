#import "UserParse.h"
#import "UserWrapper.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

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
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
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
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:user.username];
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

- (void)enableAutomaticUser
{
    [PFUser enableAutomaticUser];
}

-(PFQuery*)heroineQuery:(NSString*)twID
{
    PFQuery *q = [PFQuery queryWithClassName:@"Heroine"];
    [q whereKey:@"twID" equalTo:@([twID longLongValue])];
    // TODO enable cache
    return q;
}

- (void)fetchHeroine:(NSString *)ids
{
    PFQuery *q = [PFQuery queryWithClassName:@"Heroine"];
    NSMutableArray *numIds = [@[] mutableCopy];
    for (NSString *e in [ids componentsSeparatedByString:@","]) {
        [numIds addObject:@([e longLongValue])];
    }
    [q whereKey:@"twID" containedIn:numIds];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *arr = [@[] mutableCopy];
        for (PFObject *e in objects) {
            PFObject *hero = e[@"hero"];
            NSDictionary *heroine = @{
                                      @"twID":e[@"twID"],
                                      @"turnMin":e[@"turnMin"],
                                      @"friendShip":e[@"friendShip"],
                                      @"lastTouch":[NSNumber numberWithDouble:[e[@"lastTouch"] timeIntervalSince1970]],
                                      @"isMyHeroine":@([hero.objectId isEqualToString:[PFUser currentUser].objectId])};
            [arr addObject:heroine];
        }
        NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arr options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:json];
    }];
}

- (NSNumber*)getProgress:(NSString*)twID
{
    if ([PFUser currentUser][@"progress"] && [PFUser currentUser][@"progress"][twID]) {
        return [PFUser currentUser][@"progress"][twID];
    }
    return @0;
}

- (void)setProgress:(NSMutableDictionary*)params
{
    NSString *twID = params[@"Param1"];
    int progress = [params[@"Param2"] intValue];
    NSMutableDictionary *dic = [@{} mutableCopy];
    if ([PFUser currentUser][@"progress"]) {
        dic = [[PFUser currentUser][@"progress"] mutableCopy];
    }
    if (progress == 0) {
        [dic removeObjectForKey:twID];
    } else {
        dic[twID] = @(progress);
    }
    [PFUser currentUser][@"progress"] = dic;
    [[PFUser currentUser] saveInBackground];
}

- (void)winHeroine:(NSString*)twID
{
    [[self heroineQuery:twID] getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            object = [PFObject objectWithClassName:@"Heroine"];
            object.ACL = [PFACL ACL];
            [object.ACL setPublicReadAccess:YES];
            [object.ACL setPublicWriteAccess:YES];
            object[@"twID"] = @([twID longLongValue]);
            object[@"turnMin"] = @180;
        }
        object[@"friendShip"] = @100;
        object[@"lastTouch"] = [NSDate date];
        object[@"hero"] = [PFUser currentUser];
        [object saveInBackground];
        [self setProgress:[@{@"Param1":twID, @"Param2":@1} mutableCopy]];
    }];
}

- (void)touchHeroine:(NSString*)twID
{
    [[self heroineQuery:twID] getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            return;
        }
        object[@"lastTouch"] = [NSDate date];
        int friendShip = 0;
        if (object[@"friendShip"]) {
            friendShip = [object[@"friendShip"] intValue];
        }
        object[@"friendShip"] = @(friendShip + 1);
        [object saveInBackground];
    }];
}

- (NSNumber*)dateHeroine:(NSString*)twID
{
    PFUser *me = [PFUser currentUser];
    NSDictionary *friendShips = me[@"friendShips"];
    if (!friendShips) {
        friendShips = @{};
    }
    int friendShip = 0;
    if (friendShips[twID]) {
        friendShip = [friendShips[twID] intValue];
    }
    friendShip++;
    PFObject *heroine = [[self heroineQuery:twID] getFirstObject];
    if (!heroine) {
        heroine = [PFObject objectWithClassName:@"Heroine"];
        heroine.ACL = [PFACL ACL];
        [heroine.ACL setPublicReadAccess:YES];
        [heroine.ACL setPublicWriteAccess:YES];
        heroine[@"twID"] = @([twID longLongValue]);
        heroine[@"turnMin"] = @5;
        heroine[@"friendShip"] = @0;
    }
    NSMutableDictionary *newFriendShip = [friendShips mutableCopy];
    NSNumber *ret = @0;
    if (friendShip >= [heroine[@"friendShip"] intValue]) {
        [newFriendShip removeObjectForKey:twID];
        heroine[@"friendShip"] = @0;
        heroine[@"hero"] = [PFUser currentUser];
        heroine[@"lastTouch"] = [NSDate date];
        [heroine saveInBackground];
        ret = @1;
    } else {
        newFriendShip[twID] = @(friendShip + 1);
    }
    me[@"friendShips"] = newFriendShip;
    [me saveInBackground];
    return ret;
}

- (void)saveUserAttr:(NSMutableDictionary*)attrs
{
    NSNumber* runCount = attrs[@"Param1"];
    NSNumber* goalCount = attrs[@"Param2"];
    NSNumber* cupCount = attrs[@"Param3"];
    PFUser* user = [PFUser currentUser];
    user[@"runCount"] = runCount;
    user[@"goalCount"] = goalCount;
    user[@"cupCount"] = cupCount;
    [user saveInBackground];
}

- (NSNumber*)getUserAttr:(NSString*)attrName
{
    return [PFUser currentUser][attrName];
}

- (void)fetchScoreRank:(NSString*)col
{
    PFQuery *query = [PFUser query];
    query.limit = 100;
    [query orderByDescending:col];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *rank = [@[] mutableCopy];
        for (PFObject *e in objects) {
            [rank addObject:e[col]];
        }
        NSString* json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:rank options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:json];
    }];
}

- (void)fetchUserRank:(NSString *)col
{
    PFQuery* query = [PFUser query];
    NSNumber* myScore = [self getUserAttr:col];
    myScore = myScore ? myScore : @0;
    [query whereKey:col greaterThan:myScore];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSString* json = [NSString stringWithFormat:@"{\"rank\":%d}", number + 1];
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:json];
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
