#import "InterfaceAnalytics.h"

@interface AnalyticsGanalytics : NSObject <InterfaceAnalytics>
{
    
}

@property BOOL debug;

/**
 interfaces of protocol : InterfaceAnalytics
 */
- (void) startSession: (NSString*) appKey;
- (void) stopSession;
- (void) setSessionContinueMillis: (long) millis;
- (void) setCaptureUncaughtException: (BOOL) isEnabled;
- (void) setDebugMode: (NSNumber*) isDebugMode;
- (void) logError: (NSString*) errorId withMsg:(NSString*) message;
- (void) logEvent: (NSString*) eventId;
- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap;
- (void) logTimedEventBegin: (NSString*) eventId;
- (void) logTimedEventEnd: (NSString*) eventId;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

// GoogleAnalytics
- (void)setUserID:(NSString*)userID;
- (void)screen:(NSString*)name;
- (void)social:(NSMutableDictionary*)param;

@end
