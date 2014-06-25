//
//  KonectSdk.h
//  mobile-platform
//
//  Created by rudo on 2013/02/05.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IKonectNotificationsCallback.h"

extern NSString* const AD_SCENE_INTERSTITIAL_DEFAULT;
extern NSString* const AD_SCENE_INTERSTITIAL_CUSTOM_PREFIX;
extern NSString* const AD_SCENE_LAUNCH;
extern NSString* const AD_SCENE_RESUME;
extern NSString* const AD_SCENE_LAUNCH_BY_REMOTEPUSH;
extern NSString* const AD_SCENE_LAUNCH_BY_LOCALPUSH;

extern NSString* const AD_CLOSE_REASON_BY_USER;
extern NSString* const AD_CLOSE_REASON_BY_DEVELOPER;
extern NSString* const AD_CLOSE_REASON_OVERTAKEN;
extern NSString* const AD_CLOSE_REASON_BY_OPEN_AD;

@interface KonectNotificationsAPI : NSObject

+ (void)initialize:(NSObject<IKonectNotificationsCallback>*)callback
     launchOptions:(NSDictionary*)launchOptions
             appId:(NSString*)appId;
// isTestパラメータは廃止されました(Ver.2.2)
//+ (void)initialize:(NSObject<IKonectNotificationsCallback>*)callback
//     launchOptions:(NSDictionary*)launchOptions
//             appId:(NSString*)appId
//            isTest:(BOOL)isTest;

+ (void)setRootView:(UIViewController*)root;
+ (void)setupNotifications:(NSData*)devToken;
+ (void)setupNotificationsWithString:(NSString*)devToken;
+ (void)processLocalNotifications:(UILocalNotification*)notification;
+ (BOOL)processNotifications:(NSDictionary*)userInfo;
+ (void)beginInterstitial:(NSString*)tag;
// カスタムインタースティシャルのtagパラメータが追加されました(Ver.2.4)
// 管理画面よりtag単位で表示/停止を切り替えられます
// nilを渡すとデフォルト値になります
//+ (void)beginInterstitial;
+ (void)cancelInterstitial;
+ (UILocalNotification*)scheduleLocalNotification:(NSString*)text at:(NSDate*)dateTime label:(NSString*)label;
+ (void)cancelLocalNotification:(NSString*)label;
+ (void)setAdEnabled:(BOOL)enabled;
+ (BOOL)isAdEnabled;

+ (NSString*)JSONToString:(NSDictionary*)obj;

@end
