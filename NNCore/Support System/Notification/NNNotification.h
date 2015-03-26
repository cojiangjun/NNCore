//
//  NNNotificationHandler.h
//  WeiyunHD
//
//  Created by Rico 13-1-11.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNNotification : NSObject


+ (void)listenToEvent:(NSString *)event observer:(id)observer selector:(SEL)aSelector;
+ (void)cancelListenToEvent:(NSString *)event observer:(id)observer;
+ (void)cancelListenToAllEvent:(id)observer;
+ (void)postNotificationName:(NSString *)notificationName;
+ (void)postNotificationName:(NSString *)notificationName userInfo:(NSDictionary *)infoDict;
+ (void)postNotificationName:(NSString *)notificationName userInfoObjectsAndKeys:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)postNotificationName:(NSString *)notificationName error:(NSError *)error;

@end
