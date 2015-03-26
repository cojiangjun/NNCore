//
//  NSString+Coding.m
//  NNCore
//
//  Created by Rico 13-8-7.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NSString+Coding.h"
#import "NSString+MD5HexDigest.h"

@implementation NSString (Coding)

- (NSData*)hexStringToBinary
{
    NSMutableData* result = [[NSMutableData alloc]init];
    char c, s;
    char* src_str = (char*)[self UTF8String];
    
	while(*src_str)
	{
		s = 0x20 | (*src_str++);
		if(s >= '0' && s <= '9')
			c = s - '0';
		else if(s >= 'a' && s <= 'f')
			c = s - 'a' + 10;
		else
			break;
        
		c <<= 4;
		s = 0x20 | (*src_str++);
		if(s >= '0' && s <= '9')
			c += s - '0';
		else if(s >= 'a' && s <= 'f')
			c += s - 'a' + 10;
		else
			break;
		
        [result appendBytes:&c length:1];
	}
    
	return result;
}

- (NSData *)md5Data
{
    NSString * md5Text = [self MD5];
    NSData * md5Data = [md5Text hexStringToBinary];
    return md5Data;
}


@end
