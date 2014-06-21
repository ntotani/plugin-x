#import "UserGoogleplay.h"
#import "UserWrapper.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation UserGoogleplay
{
    GPGRealTimeRoom* roomToTrack;
}

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
    [[GPPSignIn sharedInstance] authenticate];
}

- (void) logout
{
    [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"logout success"];
}

- (NSNumber*) isLogined
{
    return [[GPGManager sharedInstance] hasAuthorizer] ? @1 : @0;
}

- (NSString*) getSessionID
{
    return @"";
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

#pragma mark GPGStatusDelegate impl

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
    }
}

#pragma mark GPGRealTimeRoomDelegate impl

- (void)room:(GPGRealTimeRoom *)room didChangeStatus:(GPGRealTimeRoomStatus)status {
    roomToTrack = room;
    if (status == GPGRealTimeRoomStatusDeleted) {
        NSLog(@"GPGRoomStatusDeleted. User probably clicked cancel");
        // Tell the view controller that's currently up to
        // dismiss any modal view controllers it might have
        roomToTrack = nil;
        [[AdsWrapper getCurrentRootViewController] dismissViewControllerAnimated:YES completion:nil];
    } else if (status == GPGRealTimeRoomStatusConnecting) {
        NSLog(@"RoomStatusConnected");
    } else if (status == GPGRealTimeRoomStatusActive) {
        NSLog(@"RoomStatusActive! Game is ready to go");
        // We may have a view controller up on screen if we're using the
        // invite UI
        [[AdsWrapper getCurrentRootViewController] dismissViewControllerAnimated:YES completion:^{
            [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"onMatch"];
        }];
    } else if (status == GPGRealTimeRoomStatusAutoMatching) {
        NSLog(@"RoomStatusAutoMatching! Waiting for auto-matching to take place");
    } else if (status == GPGRealTimeRoomStatusInviting) {
        NSLog(@"RoomStatusInviting! Waiting for invites to get accepted");
    } else {
        NSLog(@"Unknown room status %d", status);
    }
}

- (void)room:(GPGRealTimeRoom *)room didReceiveData:(NSData *)data
fromParticipant:(GPGRealTimeParticipant *)participant
    dataMode:(GPGRealTimeDataMode)dataMode {
    if (!participant.isLocalParticipant) {
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
}

- (void)createQuickStartRoom {
    // 2 player auto-match room
    GPGMultiplayerConfig *config = [[GPGMultiplayerConfig alloc] init];
    config.minAutoMatchingPlayers = 1;
    config.maxAutoMatchingPlayers = 1;
    // Could also include variants or exclusive bitmasks here

    [GPGManager sharedInstance].realTimeRoomDelegate = self;
    GPGRealTimeRoomViewController *roomViewController = [[GPGRealTimeRoomViewController alloc] initAndCreateRoomWithConfig:config];
    [[AdsWrapper getCurrentRootViewController] presentViewController:roomViewController animated:YES completion:nil];
}

- (void)leaveRoom {
    if (roomToTrack) {
        [roomToTrack leave];
    }
}

- (void)sendMessage:(NSString*)message {
    [roomToTrack sendUnreliableDataToAll:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
