#import "AnalyticsGanalytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AnalyticsGanalytics

@synthesize debug = __debug;

- (void) startSession: (NSString*) appKey
{
    [[GAI sharedInstance] trackerWithTrackingId:appKey];
    [[[GAI sharedInstance] defaultTracker] set:@"&av" value:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]];
}

- (void)setUserID:(NSString *)userID
{
    [[[GAI sharedInstance] defaultTracker] set:@"&uid" value:userID];
}

- (void)screen:(NSString*)name
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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

- (void) setDebugMode: (NSNumber*) isDebugMode
{
    self.debug = [isDebugMode boolValue];
    if (self.debug) {
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelInfo];
    }
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
    return @"3.10";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

@end
