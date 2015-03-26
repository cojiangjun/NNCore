//
// Created by Rico 13-5-9.
//
// Copyright (c) 2013年 Rcio Wang. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NNThread : NSThread
+ (NNThread*)shareInstance;

- (NSRunLoop *)runLoop;
@end