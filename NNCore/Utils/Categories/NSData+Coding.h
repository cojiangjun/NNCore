//
//  NSData+Coding.h
//  Weiyun
//
//  Created by Rico 12-5-16.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Coding)

- (NSString *)md5Hash;
- (NSString*)sha1Hash;

- (NSString*)hexString;

// GZIP
- (NSData*) compressGZip;
- (NSData*) decompressGZip;

- (id) initWithGZipFile:(NSString*)path;
- (BOOL) writeToGZipFile:(NSString*)path;


@end
