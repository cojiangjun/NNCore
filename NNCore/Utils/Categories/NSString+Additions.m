//
//  NSString+Additions.m
//  WeiyunHD
//
//  Created by Rico 13-5-23.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NSString+Additions.h"
#import "NSData+Coding.h"

@implementation NSString (Additions)


- (NSString *)md5Hash
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

- (NSString*)sha1Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
}

- (uint32_t)phpHash {
    uint32_t len = (uint32_t)self.length;
    const char *p = self.UTF8String;
    
    uint32_t hash = 0;
    for (int i = 0; i < len; i++) {
        hash = ((hash <<5) + hash) + (unsigned int) p[i];
    }
    return hash;
}

+ (NSString *)stringForlonglongValue:(int64_t)value
{
    return [NSString stringWithFormat:@"%lld",value];
}

+ (NSString *)stringForIntValue:(NSInteger)value
{
    return [NSString stringWithFormat:@"%ld",(long)value];
}

- (NSString *)subStringMaxLength:(NSUInteger)maxLength
{
    if (self.length < maxLength) {
        return self;
    }
    return [self substringToIndex:maxLength];
}


- (NSString *)urlDecodeAndMoveFilePrefix
{
    if ([self hasPrefix:@"file://"]) {
        NSString * path = [self substringFromIndex:7];
        return [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
    
}

- (NSString *)urlRemoveFilePrefix
{
    if ([self hasPrefix:@"file://"]) {
        NSString * path = [self substringFromIndex:7];
        return path;
    }
    return self;
}

@end
