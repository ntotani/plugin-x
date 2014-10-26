#import <Foundation/Foundation.h>
#import "InterfaceUser.h"
#import <Parse/Parse.h>

@interface UserParse : NSObject <InterfaceUser, PFLogInViewControllerDelegate>
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
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void)loginWithTwitter;
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error;
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController;

- (NSString*)getTwitterID;
- (void)fetchHeroine:(NSString *)ids;
- (NSNumber*)getProgress:(NSString*)twID;
- (void)setProgress:(NSMutableDictionary*)params;
- (NSNumber*)getReserve:(NSString*)twID;
- (void)setReserve:(NSMutableDictionary*)params;
- (NSNumber*)getTouch:(NSString*)twID;
- (void)setTouch:(NSMutableDictionary*)params;
- (void)winHeroine:(NSString*)twID;
- (void)touchHeroine:(NSString*)twID;

- (NSString*)twitterApi:(NSMutableDictionary*)params;

@end
