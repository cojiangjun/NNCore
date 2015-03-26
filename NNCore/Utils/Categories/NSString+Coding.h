//
//  NSString+Coding.h
//  NNCore
//
//  Created by Rico 13-8-7.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Coding)

- (NSData*)hexStringToBinary;

- (NSData *)md5Data;

@end
