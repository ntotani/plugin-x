#import "UserParse.h"
#import "UserWrapper.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);
#define LOVER_PROGRESS 100

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

-(PFQuery*)heroineQuery:(NSString*)twID
{
    PFQuery *q = [PFQuery queryWithClassName:@"Heroine"];
    [q whereKey:@"twID" equalTo:@([twID longLongValue])];
    // TODO enable cache
    return q;
}

-(NSDictionary*)pfobj2dic:(PFObject*)heroine
{
    PFObject *hero = heroine[@"hero"];
    int turnSec = [heroine[@"turnMin"] intValue] * 60;
    NSDate *now = [NSDate date];
    NSDate *dateEnd = [NSDate dateWithTimeInterval:turnSec sinceDate:heroine[@"lastTouch"]];
    NSDate *restEnd = [self getRestEnd:heroine[@"twID"] tunrSec:turnSec];
    NSDate *releaseAt = dateEnd;
    if ([dateEnd compare:restEnd] == NSOrderedAscending) {
        releaseAt = restEnd;
    }
    BOOL anyFriendShip = [self currentFriendShip:heroine] > 0;
    BOOL isMyHeroine = anyFriendShip && [hero.objectId isEqualToString:[PFUser currentUser].objectId];
    int prog = [[self getProgress:[heroine[@"twID"] stringValue]] intValue];
    return @{
             @"isMyHeroine":isMyHeroine ? @YES : @NO,
             @"anyHero":anyFriendShip ? @YES : @NO,
             @"dateNow":[now compare:dateEnd] == NSOrderedAscending ? @YES : @NO,
             @"restNow":[now compare:restEnd] == NSOrderedAscending ? @YES : @NO,
             @"releaseAt":@((int)[releaseAt timeIntervalSince1970]),
             @"friendShip":@([self currentFriendShip:heroine]),
             @"okRate":@(100 - 70 * [self currentFriendShip:heroine] / 100),
             @"broken":prog >= LOVER_PROGRESS && !isMyHeroine ? @YES : @NO};
}

-(NSDate*)getRestEnd:(NSNumber*)twID tunrSec:(int)turnSec
{
    int myTouch = [[self getTouch:[twID stringValue]] intValue];
    return [NSDate dateWithTimeIntervalSince1970:myTouch + turnSec];
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
        NSMutableDictionary *heroines = [@{} mutableCopy];
        NSDate *now = [NSDate date];
        for (NSNumber *e in numIds) {
            NSDate *restEnd = [self getRestEnd:e tunrSec:180 * 60];
            heroines[[e stringValue]] = @{
                                          @"isMyHeroine":@NO,
                                          @"anyHero":@NO,
                                          @"dateNow":@NO,
                                          @"restNow":[now compare:restEnd] == NSOrderedAscending ? @YES : @NO,
                                          @"releaseAt":@((int)[restEnd timeIntervalSince1970]),
                                          @"friendShip":@0,
                                          @"okRate":@100,
                                          @"broken":@NO};
        }
        for (PFObject *e in objects) {
            heroines[[e[@"twID"] stringValue]] = [self pfobj2dic:e];
        }
        NSData *d = [NSJSONSerialization dataWithJSONObject:heroines options:kNilOptions error:nil];
        NSString *json = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:json];
    }];
}

- (void)fetchGainedHeroine
{
    NSDictionary *progress = [PFUser currentUser][@"progress"];
    [self fetchHeroine:[progress.allKeys componentsJoinedByString:@","]];
}

- (NSNumber*)getUserAttr:(NSString*)twID attr:(NSString*)attr
{
    if ([PFUser currentUser][attr] && [PFUser currentUser][attr][twID]) {
        return [PFUser currentUser][attr][twID];
    }
    return @0;
}

- (void)setUserAttr:(NSMutableDictionary*)params attr:(NSString*)attr
{
    NSString *twID = params[@"Param1"];
    int progress = [params[@"Param2"] intValue];
    NSMutableDictionary *dic = [@{} mutableCopy];
    if ([PFUser currentUser][attr]) {
        dic = [[PFUser currentUser][attr] mutableCopy];
    }
    if (progress == 0) {
        [dic removeObjectForKey:twID];
    } else {
        dic[twID] = @(progress);
    }
    [PFUser currentUser][attr] = dic;
}

- (NSNumber*)getProgress:(NSString*)twID
{
    return [self getUserAttr:twID attr:@"progress"];
}

- (void)setProgress:(NSMutableDictionary*)params
{
    [self setUserAttr:params attr:@"progress"];
}

- (NSNumber*)getReserve:(NSString*)twID
{
    return [self getUserAttr:twID attr:@"reserve"];
}

- (void)setReserve:(NSMutableDictionary*)params
{
    [self setUserAttr:params attr:@"reserve"];
}

- (NSNumber*)getTouch:(NSString*)twID
{
    return [self getUserAttr:twID attr:@"touch"];
}

- (void)setTouch:(NSMutableDictionary*)params
{
    [self setUserAttr:params attr:@"touch"];
}

- (void)commitUser
{
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
        [self setProgress:[@{@"Param1":twID, @"Param2":@(LOVER_PROGRESS)} mutableCopy]];
        NSMutableDictionary *reset = [@{@"Param1":twID, @"Param2":@0} mutableCopy];
        [self setReserve:reset];
        [self setTouch:reset];
        [PFObject saveAllInBackground:@[object, [PFUser currentUser]]];
    }];
}

- (int)currentFriendShip:(PFObject*)heroine
{
    int pastMin = [[NSDate date] timeIntervalSinceDate:heroine[@"lastTouch"]] / 60;
    int pastTurn = pastMin / [heroine[@"turnMin"] intValue];
    int friendShip = [heroine[@"friendShip"] intValue] - pastTurn * 4;
    return MAX(friendShip, 0);
}

- (void)touchHeroine:(NSString*)twID
{
    [[self heroineQuery:twID] getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            return;
        }
        object[@"friendShip"] = @(MIN([self currentFriendShip:object] + 30, 100));
        object[@"lastTouch"] = [NSDate date];
        [object saveInBackground];
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
