//
//  NSDictionary+Adding.m
//  Weiyun
//
//  Created by Rico 12-9-12.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import "NSDictionary+Adding.h"

@implementation NSDictionary (Adding)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    return [self objectForKey:key] == nil ? defaultValue
    : [[self objectForKey:key] boolValue];
}

- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
	return [self objectForKey:key] == nil
    ? defaultValue : [[self objectForKey:key] intValue];
}

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
	NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == nil) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		return mktime(&created);
	}
	return defaultValue;
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
	return [self objectForKey:key] == nil
    ? defaultValue : [[self objectForKey:key] longLongValue];
}

- (long long)getLongLongValueDefaultValueZeroForKey:(NSString *)key{
    return [self getLongLongValueValueForKey:key defaultValue:0];
}



- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
	return [self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null] 
    ? defaultValue : [self objectForKey:key];
}

//key 大小写不敏感
- (id)objectForCaseInsensitiveKey:(id)aKey
{
    if (nil == aKey) {
        return nil;
    }
    
    id object = [self objectForKey:aKey];
    
    if (object)
    {
        return object;
    }
    
    if (nil == object)
    {
        NSArray * keyInDicts = [self allKeys];
        for (NSString * keyInDict in keyInDicts) 
        {
            if ([aKey caseInsensitiveCompare:keyInDict] == NSOrderedSame) 
            {
                object = [self objectForKey:keyInDict];
                break;
            }
        }
        
    }
    
    return object;
    
}




@end
