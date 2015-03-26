//
//  NSString+MD5HexDigest.m
//  Weiyun
//
//  Created by Rico 12-7-4.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import "NSString+MD5HexDigest.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5HexDigest)

- (NSString *)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char result[CC_MD5_DIGEST_LENGTH];\
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (unsigned)strlen(ptr), result);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSString *MD5Str;
    MD5Str = [[NSString stringWithFormat:
               @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
               result[0], result[1], result[2], result[3],
               result[4], result[5], result[6], result[7],
               result[8], result[9], result[10], result[11],
               result[12], result[13], result[14], result[15]
               ] lowercaseString];
    
    return MD5Str;
}

@end
