#import "AnalyticsMorph.h"
#import "ParseUtils.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AnalyticsMorph

@synthesize debug = __debug;

- (NSString*) parseNoun: (NSString*) text
{
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[NSLinguisticTagSchemeTokenType] options:0];
    [tagger setString:text];
    __block NSMutableArray *nouns = [@[] mutableCopy];
    [tagger enumerateTagsInRange:NSMakeRange(0, text.length) scheme:NSLinguisticTagSchemeTokenType options:0 usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        if ([tag isEqualToString:NSLinguisticTagWord] && tokenRange.length >= 3) {
            [nouns addObject:[text substringWithRange:tokenRange]];
        }
    }];
    return [ParseUtils NSDictionaryToNSString:nouns];
}

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
    self.debug = isDebugMode;
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
