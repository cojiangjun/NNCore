//
//  NNNotificationHandler.m
//  WeiyunHD
//
//  Created by Rico 13-1-11.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NNNotification.h"

@implementation NNNotification

+ (void)listenToEvent:(NSString *)event observer:(id)observer selector:(SEL)aSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:event object:nil];
}

+ (void)cancelListenToEvent:(NSString *)event observer:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:event object:nil];
}

+ (void)cancelListenToAllEvent:(id)observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

+ (void)postNotificationName:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

+ (void)postNotificationName:(NSString *)notificationName userInfo:(NSDictionary *)infoDict
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:infoDict];
}

+ (void)postNotificationName:(NSString *)notificationName error:(NSError *)error
{
    [self postNotificationName:notificationName userInfoObjectsAndKeys:error, @"error", nil];
}


+ (void)postNotificationName:(NSString *)notificationName userInfoObjectsAndKeys:(id)object, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableDictionary *userInfo = nil;
    id eachObject = nil;
    id eachKey = nil;
    va_list arg_list;
    
    va_start(arg_list, object);
    
    if (object) {
        userInfo = [NSMutableDictionary dictionary];
        id firstKey = va_arg(arg_list, id);
        if (firstKey) {
            [userInfo setObject:object forKey:firstKey];
        }
        
        while ((eachObject = va_arg(arg_list, id))
               && (eachKey = va_arg(arg_list, id))) {
            [userInfo setObject:eachObject forKey:eachKey];
        }
    }

    [NNNotification postNotificationName:notificationName userInfo:userInfo];
}


@end
