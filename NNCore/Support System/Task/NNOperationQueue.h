//
//  NNOperationQueue.h
//  WeiyunModel
//
//  Created by Rico on 13-7-11.
//  Copyright (c) 2013年 Rcio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNOperation.h"

@protocol NNOperationQueueDelegate;

@interface NNOperationQueue : NSObject

@property (nonatomic, assign) NSUInteger maxConcurrent;
@property (nonatomic, assign) NSInteger maxQueueSize;

@property (nonatomic, assign) BOOL isSuspended;
@property (nonatomic, weak) NSObject <NNOperationQueueDelegate> *delegate;

- (void)addOperation:(NNOperation *)operation head:(BOOL)head;
- (void)setSuspended:(BOOL)suspend;
- (void)stopOneOperation;
- (void)schedOperation:(NNOperation *)operation;
- (BOOL)isOperationRunning:(NNOperation *)operation;

- (void)clearQueue;
- (NSArray *)runningOperations;

@end

@protocol NNOperationQueueDelegate
@optional

- (void)NNOperationQueue:(NNOperationQueue *)queue operationDidStop:(NNOperation *)operation;

@end