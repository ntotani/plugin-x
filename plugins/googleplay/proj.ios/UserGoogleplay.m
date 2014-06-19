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
}

- (void) login
{
    OUTPUT_LOG(@"login");
    [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@"login success"];
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

@end
