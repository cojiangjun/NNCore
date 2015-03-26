//
//  NNOperation.h
//  WeiyunModel
//
//  Created by Rico on 13-7-11.
//  Copyright (c) 2013年 Rcio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNOperation : NSObject

@property (atomic, assign) BOOL isStopped;       //任务已经被停止
@property (atomic, assign) BOOL isCanceled;      //任务已经被取消，可能还未停止

- (void)start;
- (void)stop;
- (void)cancel;
- (void)reset;

@end