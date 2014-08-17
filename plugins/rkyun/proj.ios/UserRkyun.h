#import "InterfaceUser.h"

@interface UserRkyun : NSObject <InterfaceUser>

/**
 * @brief interfaces of protocol : InterfaceUser
 */
- (void) login;
- (void) logout;
- (BOOL) isLogined;
- (NSString*) getSessionID;
- (void) setDebugMode:(BOOL)debug;

- (void) fetchFriends:(NSString*)cursor;
- (void) process:(NSString*)heroine;

@end
