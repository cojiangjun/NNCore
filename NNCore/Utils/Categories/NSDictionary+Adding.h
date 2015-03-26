//
//  NSDictionary+Adding.h
//  Weiyun
//
//  Created by Rico 12-9-12.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Adding)


- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue;

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue;

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue;

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue;

- (long long)getLongLongValueDefaultValueZeroForKey:(NSString *)key;


- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

//key 大小写不敏感
- (id)objectForCaseInsensitiveKey:(id)aKey;

@end
