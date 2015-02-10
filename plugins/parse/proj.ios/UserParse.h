#import <Foundation/Foundation.h>
#import "InterfaceUser.h"
#import <Parse/Parse.h>

@interface UserParse : NSObject <InterfaceUser>
{
}

@property BOOL debug;

/**
 interfaces from InterfaceUser
 */
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) login;
- (void) logout;
- (NSNumber*) isLoggedIn;
- (NSString*) getSessionID;
- (void) setDebugMode: (NSNumber*) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void)loginWithTwitter;

- (NSString*)getTwitterID;
- (NSString*)twitterApi:(NSMutableDictionary*)params;
- (void)cloudFunc:(NSMutableDictionary*)params;

@end
