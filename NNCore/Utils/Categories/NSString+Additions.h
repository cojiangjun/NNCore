//
//  NSString+Additions.h
//  WeiyunHD
//
//  Created by Rico 13-5-23.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)
/**
 * Calculate the md5 hash of this string using CC_MD5.
 *
 * @return md5 hash of this string
 */
@property (nonatomic, readonly) NSString* md5Hash;

/**
 * Calculate the SHA1 hash of this string using CommonCrypto CC_SHA1.
 *
 * @return NSString with SHA1 hash of this string
 */
@property (nonatomic, readonly) NSString* sha1Hash;

- (uint32_t)phpHash;

+ (NSString *)stringForlonglongValue:(int64_t)value;

+ (NSString *)stringForIntValue:(NSInteger)value;

- (NSString *)subStringMaxLength:(NSUInteger)maxLength;

/*
 * urlDecodeAndMoveFilePrefix
 * @brief 移除本地文件前缀，并进行url解码 <#...#>
 * @param <#param#> <#...#>
 * @param <#param#> <#...#>
 * @return <#return#>
 */
- (NSString *)urlDecodeAndMoveFilePrefix;

- (NSString *)urlRemoveFilePrefix;


@end
