//
//  NSMutableDictionary+Adding.m
//  NNCore
//
//  Created by Rico 13-11-10.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NSMutableDictionary+Adding.h"

@implementation NSMutableDictionary (Adding)

- (NSDictionary *)unMutableDic
{
    if (self.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:self];
}

@end
