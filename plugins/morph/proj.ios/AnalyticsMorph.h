#import "InterfaceAnalytics.h"

@interface AnalyticsMorph : NSObject <InterfaceAnalytics>
{
    
}

@property BOOL debug;

- (NSString*) parseNoun: (NSString*) text;

/**
 interfaces of protocol : InterfaceAnalytics
 */
- (void) startSession: (NSString*) appKey;
- (void) stopSession;
- (void) setSessionContinueMillis: (long) millis;
- (void) setCaptureUncaughtException: (BOOL) isEnabled;
- (void) setDebugMode: (BOOL) isDebugMode;
- (void) logError: (NSString*) errorId withMsg:(NSString*) message;
- (void) logEvent: (NSString*) eventId;
- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap;
- (void) logTimedEventBegin: (NSString*) eventId;
- (void) logTimedEventEnd: (NSString*) eventId;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

@end
