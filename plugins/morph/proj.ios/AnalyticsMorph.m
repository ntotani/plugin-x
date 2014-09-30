#import "AnalyticsMorph.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AnalyticsMorph

@synthesize debug = __debug;

- (void) startSession: (NSString*) appKey
{
}

- (void) stopSession
{
}

- (void) setSessionContinueMillis: (long) millis
{
}

- (void) setCaptureUncaughtException: (BOOL) isEnabled
{
}

- (void) setDebugMode: (BOOL) isDebugMode
{
}

- (void) logError: (NSString*) errorId withMsg:(NSString*) message
{
}

- (void) logEvent: (NSString*) eventId
{
}

- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
}

- (void) logTimedEventBegin: (NSString*) eventId
{
}

- (void) logTimedEventEnd: (NSString*) eventId
{
}

- (NSString*) getSDKVersion
{
    return @"0.0.1";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

@end
