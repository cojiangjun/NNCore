//
//  NSMutableArray+Adding.m
//  NNCore
//
//  Created by Rico 13-9-24.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NSMutableArray+Adding.h"

@implementation NSMutableArray (Adding)


- (NSArray *)unMutableArray
{
    if (self.count == 0) {
        return nil;
    }
    return [NSArray arrayWithArray:self];
}

@end
