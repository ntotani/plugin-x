//
//  IKonectCallback.h
//  mobile-platform
//
//  Created by rudo on 2013/02/13.
//
//

#import <Foundation/Foundation.h>

@protocol IKonectNotificationsCallback<NSObject>

@optional
- (void)onLaunchFromNotification:(NSString*)notificationsId message:(NSString*)message extra:(NSDictionary*)extra;

@optional
- (void)onCompleteAdRequest:(BOOL)success;
// Ver.2.5.0からの追加
- (void)onCompleteAdRequest:(NSString*)scene success:(BOOL)success;
// Ver.2.5.0からの追加
- (void)onShowAd:(NSString*)scene;
// Ver.2.5.0からの追加
- (void)onCloseAd:(NSString*)scene reason:(NSString*)reason;

@end
