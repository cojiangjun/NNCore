//
//  UIDeviceEx.h
//  QQDiskLogin
//
//  Created by Rico 11-12-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>

extern NSString* const WIFI_INTERFACE_NAME; 
extern NSString* const WIFI_INTERFACE_ADDR;
extern NSString* const WIFI_INTERFACE_NETMASK;
extern NSString* const WIFI_INTERFACE_BROADCAST_ADDR;


@interface UIDevice(Ex) 


+ (NSString*)getCurrentIPAddress:(NSString*)interfaceName;
+ (NSString*)localWifiIPAddress;
+ (BOOL) networkAvailable;
+ (BOOL) activeWLAN;
+ (BOOL) activeWWAN;

+ (NSString*) currentWifiName;
+ (NSString*) currentWifiAPMac;

/**
 *
 * get the wifi address info
 *
 */
+ (NSDictionary*)getLocalWifiIPAddressInfo;

//取得mac地址
+ (NSString *) wifiMacAddr;
//取得设备型号
+ (NSString *)getCurrentPlatform;


//取得本地原始的设备型号，未经转化
+ (NSString *)getLocalPlatformName;


//判断iOS设备类型
+ (BOOL)isIPhone;
+ (BOOL)isIPodTouch;
+ (BOOL)isIPad;

@end
