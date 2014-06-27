#import <Foundation/Foundation.h>
#import "InterfaceUser.h"
#import <GooglePlus/GooglePlus.h>
#import <GooglePlayGames/GooglePlayGames.h>

/*
typedef enum {
    kSizeBanner = 1,
    kSizeIABMRect,
    kSizeIABBanner,
    kSizeIABLeaderboard,
    kSizeSkyscraper,
} AdmobSizeEnum;

typedef enum {
    kTypeBanner = 1,
    kTypeFullScreen,
} AdmobType;
 */

@interface UserGoogleplay : NSObject <InterfaceUser, GPPSignInDelegate, GPGStatusDelegate>
{
}

@property BOOL debug;
@property (copy, nonatomic) NSString* strClientID;
/*
@property (assign, nonatomic) GADBannerView* bannerView;
@property (assign, nonatomic) NSMutableArray* testDeviceIDs;
 */

/**
 interfaces from InterfaceUser
 */
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) login;
- (void) logout;
- (BOOL) isLogined;
- (NSString*) getSessionID;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

/**
 interface for Googleplay SDK
 */
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error;
- (void)didFinishGamesSignInWithError:(NSError *)error;
- (void)didFinishGamesSignOutWithError:(NSError *)error;

@end
