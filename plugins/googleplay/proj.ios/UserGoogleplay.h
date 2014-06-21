#import <Foundation/Foundation.h>
#import "InterfaceUser.h"
#import <GooglePlus/GooglePlus.h>
#import <GooglePlayGames/GooglePlayGames.h>

@interface UserGoogleplay : NSObject <InterfaceUser, GPPSignInDelegate, GPGStatusDelegate, GPGRealTimeRoomDelegate>
{
}

@property BOOL debug;
@property (copy, nonatomic) NSString* strClientID;

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
 interface for GPPSignInDelegate
 */
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error;

/**
 interface for GPGStatusDelegate
 */
- (void)didFinishGamesSignInWithError:(NSError *)error;
- (void)didFinishGamesSignOutWithError:(NSError *)error;

/**
 interface for GPGRealTimeRoomDelegate
 */
- (void)room:(GPGRealTimeRoom *)room didChangeStatus:(GPGRealTimeRoomStatus)status;
- (void)room:(GPGRealTimeRoom *)room didReceiveData:(NSData *)data
fromParticipant:(GPGRealTimeParticipant *)participant
    dataMode:(GPGRealTimeDataMode)dataMode;

- (void)createQuickStartRoom;
- (void)leaveRoom;
- (void)sendMessage:(NSString*)message;

@end
