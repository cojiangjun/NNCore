//
//  NSURL+UTF8.m
//  NNCore
//
//  Created by Rico 13-11-22.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NSURL+UTF8.h"

@implementation NSURL (UTF8)

+ (NSURL *)URLWithUTF8String:(NSString *)string {
    return [NSURL URLWithString:[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end
