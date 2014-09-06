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
- (NSNumber*) isLogined;
- (NSString*) getSessionID;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error;
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController;

- (void)enableAutomaticUser;
- (void)saveUserAttr:(NSMutableDictionary*)attrs;
- (NSNumber*)getUserAttr:(NSString*)attrName;
- (void)fetchScoreRank:(NSString*)col;
- (void)fetchUserRank:(NSString *)col;
- (NSString*)twitterApi:(NSMutableDictionary*)params;

@end
