//
//  AMoAdSDK.h
//  AMoAdSDK
//
//  Copyright © CyberAgent, Inc. All Rights Reserved.
//

#import <UIKit/UIKit.h>
#import "APSDKAd.h"

@interface AMoAdSDK : NSObject {
}

/*
 * Wallの表示.
 */
+ (UIViewController *) showAppliPromotionWall:(UIViewController *)owner;
+ (UIViewController *) showAppliPromotionWall:(UIViewController *)owner
                                  orientation:(UIInterfaceOrientation)orientation;
+ (UIViewController *) showAppliPromotionWall:(UIViewController *)owner onStatusArea:(BOOL)onStatusArea;
+ (UIViewController *) showAppliPromotionWall:(UIViewController *)owner
                                  orientation:(UIInterfaceOrientation)orientation
                                 onStatusArea:(BOOL)onStatusArea;
+ (UIViewController *) showAppliPromotionWall:(UIViewController *)owner
                                  orientation:(UIInterfaceOrientation)orientation
                                 onStatusArea:(BOOL)onStatusArea
                             onClickTriggerId:(NSString*)onClickTriggerID;


/*
 * Wallの表示が初めてかどうかのチェック.
 */
+ (BOOL)isFirstTimeInToday;

/*
 * UUIDの送信.
 */
+ (void)sendUUID;

/*
 * Wall誘導枠IDを送信し、Wall誘導枠画像を取得.
 */
+ (void)sendTriggerID:(UIViewController *)owner trigger:(NSString *)TriggerID callback:(SEL)callback;
+ (void)sendTriggerID:(NSString *)triggerID
        callbackBlock:(void(^)(NSInteger sts, NSString *url, NSInteger width, NSInteger height))callbackBlock;

/*
 * Wall誘導枠となっている、対象ボタンが押下時のWall表示。
 */
+ (void)pushTrigger:(UIViewController *)owner
		  TriggerID:(NSString *)triggerID;
+ (void)pushTrigger:(UIViewController *)owner
		orientation:(UIInterfaceOrientation)orientation
		  TriggerID:(NSString *)triggerID;
+ (void)pushTrigger:(UIViewController *)owner
		  TriggerID:(NSString *)triggerID
	   onStatusArea:(BOOL)onStatusArea;
+ (void)pushTrigger:(UIViewController *)owner
		orientation:(UIInterfaceOrientation)orientation
		  TriggerID:(NSString *)triggerID
	   onStatusArea:(BOOL)onStatusArea;


/*
 * Wall誘導枠となっている、対象ボタンが押下時のPopup表示。
 */
+ (void)popupDisp:(UIViewController *)owner
		TriggerID:(NSString *)triggerID;
+ (void)popupDisp:(UIViewController *)owner
	  orientation:(UIInterfaceOrientation)orientation
		TriggerID:(NSString *)triggerID;
+ (void)popupDisp:(UIViewController *)owner
		TriggerID:(NSString *)triggerID
	 onStatusArea:(BOOL)onStatusArea;
+ (void)popupDisp:(UIViewController *)owner
	  orientation:(UIInterfaceOrientation)orientation
		TriggerID:(NSString *)triggerID
	 onStatusArea:(BOOL)onStatusArea;
+ (void)popupDisp:(UIViewController *)owner
		TriggerID:(NSString *)triggerID
		 callback:(SEL)callback;
+ (void)popupDisp:(UIViewController *)owner
	  orientation:(UIInterfaceOrientation)orientation
		TriggerID:(NSString *)triggerID
		 callback:(SEL)callback;
+ (void)popupDisp:(UIViewController *)owner
		TriggerID:(NSString *)triggerID
	 onStatusArea:(BOOL)onStatusArea
		 callback:(SEL)callback;
+ (void)popupDisp:(UIViewController *)owner
	  orientation:(UIInterfaceOrientation)orientation
		TriggerID:(NSString *)triggerID
	 onStatusArea:(BOOL)onStatusArea
		 callback:(SEL)callback;

/*
 * Unity用Wall誘導枠のcallback用.
 */
+ (void)setImageDelegate:(id)delegate;
+ (void)popupTriggerDelegate:(id)delegate;

//----------------------------------------------------------------------------------------------------
+(void)initSDK;
+(void)getAdsWithCount:(NSInteger)count completionBlock:(void(^)(NSInteger sts, NSArray* ads))completionBlock;
+(void)getAdsEnableExludeAppsWithCount:(NSInteger)count completionBlock:(void(^)(NSInteger sts, NSArray* ads))completionBlock;
+(void)clickWithAd:(APSDKAd*)ad;

@end
