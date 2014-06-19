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
    signIn.shouldFetchGoogleUserID =YES;
}

- (void) login
{
    OUTPUT_LOG(@"login");
    //[UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@"login success"];
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
    NSLog(@"Finished with auth.");
    if (error == nil && auth) {
        NSLog(@"Success signing in to Google! Auth object is %@", auth);
        
        // Eventually, you'll want to do something here.
        
    } else {
        NSLog(@"Failed to log into Google\n\tError=%@\n\tAuthObj=%@",error,auth);
    }
}

@end
