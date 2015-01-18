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
- (void) setDebugMode: (NSNumber*) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void)loginWithTwitter;
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error;
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController;

- (NSString*)getTwitterID;
- (NSString*)twitterApi:(NSMutableDictionary*)params;
- (void)cloudFunc:(NSMutableDictionary*)params;

@end
