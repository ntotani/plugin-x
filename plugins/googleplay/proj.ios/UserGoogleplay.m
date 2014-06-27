#import "UserGoogleplay.h"
#import "UserWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation UserGoogleplay

@synthesize debug = __debug;
@synthesize strClientID = __ClientID;
//@synthesize testDeviceIDs = __TestDeviceIDs;

- (void) dealloc
{
    /*
    if (self.bannerView != nil) {
        [self.bannerView release];
        self.bannerView = nil;
    }

    if (self.testDeviceIDs != nil) {
        [self.testDeviceIDs release];
        self.testDeviceIDs = nil;
    }
     */
    [super dealloc];
}

#pragma mark InterfaceUser impl

- (void) configDeveloperInfo: (NSMutableDictionary*) cpInfo
{
    self.strClientID = (NSString*) [cpInfo objectForKey:@"ClientID"];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.clientID = self.strClientID;
    signIn.scopes = @[@"https://www.googleapis.com/auth/games"];
    signIn.language = [[NSLocale preferredLanguages] objectAtIndex:0];
    signIn.delegate = self;
    signIn.shouldFetchGoogleUserID = YES;
    [GPGManager sharedInstance].statusDelegate = self;
    [signIn trySilentAuthentication];
}

- (void) login
{
    OUTPUT_LOG(@"login");
    [[GPPSignIn sharedInstance] authenticate];
}

- (void) logout
{
    OUTPUT_LOG(@"logout");
    [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"logout success"];
}

- (BOOL) isLogined
{
    OUTPUT_LOG(@"isLogined");
    return YES;
}

- (NSString*) getSessionID
{
    return @"hoge";
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    self.debug = isDebugMode;
}

- (NSString*) getSDKVersion
{
    return @"1.0.0";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

#pragma mark GPPSignInDelegate impl

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    OUTPUT_LOG(@"Finished with auth.");
    if (error == nil && auth) {
        OUTPUT_LOG(@"Success signing in to Google! Auth object is %@", auth);
        [self startGoogleGamesSignIn];
    } else {
        OUTPUT_LOG(@"Failed to log into Google\n\tError=%@\n\tAuthObj=%@",error,auth);
        [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"login failed"];
    }
}

- (void)startGoogleGamesSignIn {
    // The GPPSignIn object has an auth token now. Pass it to the GPGManager.
    [[GPGManager sharedInstance] signIn:[GPPSignIn sharedInstance]
                     reauthorizeHandler:^(BOOL requiresKeychainWipe, NSError *error) {
                         // If you hit this, auth has failed and you need to authenticate.
                         // Most likely you can refresh behind the scenes
                         if (requiresKeychainWipe) {
                             [[GPPSignIn sharedInstance] signOut];
                         }
                         [[GPPSignIn sharedInstance] authenticate];
                     }];

    // Let's also ask if it's okay to send push notifciations
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
}

- (void)didFinishGamesSignInWithError:(NSError *)error {
    if (error) {
        OUTPUT_LOG(@"ERROR during sign in: %@", [error localizedDescription]);
        [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"login failed"];
    } else {
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@"login succeed"];
    }
}

- (void)didFinishGamesSignOutWithError:(NSError *)error {
    if (error) {
        OUTPUT_LOG(@"ERROR during sign out: %@", [error localizedDescription]);
    } else {
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"logout succeed"];
    }
}

@end
