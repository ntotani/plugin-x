//
//  AidAdAgent.h
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class AidAdAgent, AidAdDialogViewController;
@protocol AidAdDialogBlocker;
@protocol AidAdAgentDelegate;


///////////////////////////////////////////////////////////////////////////

@interface AidAd : NSObject 

+ (NSString*)version;
+ (AidAdAgent*)agentForMedia:(NSString*)mediaCode;

@end



///////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(char, AidAdCreativeStyle)
{
  kAidAdCreativeStyle_PLAIN_TEXT = 't',
  kAidAdCreativeStyle_POPUP_IMAGE= 'i',
};


@interface AidAdAgent : NSObject

@property (retain) id<AidAdDialogBlocker> dialogBlocker;
@property (assign) id<AidAdAgentDelegate> delegate;
@property (assign) AidAdCreativeStyle preferredCreativeStyle;

+ (AidAdCreativeStyle) defaultPreferredCreativeStyle;
+ (void) setDefaultPreferredCreativeStyle:(AidAdCreativeStyle)style;


- (instancetype)initWithMediaCode:(NSString*)mediaCode;


- (void)startLoading;
- (void)stopLoading;


- (NSUInteger)countAttemptsToShowDialog;

- (BOOL)showDialog;
- (void)closeDialog;

- (BOOL)isDialogShown;
- (BOOL)hasLoadedContent;

- (NSString*)mediaCode;


@end


///////////////////////////////////////////////////////////////////////////

@protocol AidAdDialogBlocker <NSObject>

- (BOOL)shouldBlockDialog:(AidAdAgent*)ctrl;

@end


@protocol AidAdAgentDelegate <NSObject>

@optional

- (void)adAgentDidOpenDialog:(AidAdAgent*)agent;
- (void)adAgentDidCloseDialog:(AidAdAgent*)agent;

- (void)adAgentDidDetectCloseButtonWasTapped:(AidAdAgent*)agent;
- (void)adAgentDidDetectDetailButtonWasTapped:(AidAdAgent*)agent;

@end

