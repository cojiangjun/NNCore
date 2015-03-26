//
//  NNOperationQueue.m
//  WeiyunModel
//
//  Created by Rico on 13-7-11.
//  Copyright (c) 2013年 Rcio. All rights reserved.
//

#import "NNOperationQueue.h"

static NSString *kModuleDataTransfer = @"TRANS";
static NSString *kNNOperationStateIsStop = @"isStopped";

@interface NNOperationQueue ()

@property (nonatomic, strong) NSMutableArray *waitingQueue;
@property (nonatomic, strong) NSMutableSet *runningSet;

@property (nonatomic, strong) NNRWLock *waitingQueueLock;
@property (nonatomic, strong) NNRWLock *runningSetLock;

@end

@implementation NNOperationQueue
- (id)init {
    self = [super init];
    
    _maxConcurrent = 1;
    _maxQueueSize  = 0; // 默认无限制
    
    _waitingQueue = [[NSMutableArray alloc] init];
    _runningSet = [[NSMutableSet alloc] init];
    
    _waitingQueueLock = [[NNRWLock alloc] init];
    _runningSetLock = [[NNRWLock alloc] init];

    return self;
}

#pragma mark Getter & Setter
- (void)setMaxConcurrent:(NSUInteger)maxConcurrent {
    _maxConcurrent = maxConcurrent;
    [self reSched];
}

#pragma mark Internal Function
/**
 * reSche
 * @brief 对整个运行队列进行重新调度
 */
- (void)reSched {
    if (_isSuspended) {
        return;
    }
    
    /* 要对两个队列进行读写操作，全部上锁 */
    [self lockAllData];
    
    if (_runningSet.count < _maxConcurrent
        && _waitingQueue.count) {
        NNOperation *operation = [_waitingQueue objectAtIndex:0];
        if (operation) {
            /* 转换队列 */
            [_waitingQueue removeObjectAtIndex:0];
            [_runningSet addObject:operation];
            
            /* 丢到异步队列上执行 start 方法开始执行 */
            dispatch_async(NNNetworkQueue, ^{
                [operation start];
            });
            
            NNLogDebug(kModuleDataTransfer, @"Operation %@ start in queue %@", operation, self);
        }
    }
    
    [self unLockAllData];
}

- (void)stopAll {
    // 两段式 stop，防止 KVO 中死锁
    [_runningSetLock lockRead];
    NSSet *runningSetCopy = [NSSet setWithSet:_runningSet];
    [_runningSetLock unLockRead];
    
    for (NNOperation *operation in runningSetCopy) {
        [operation stop];
        
        /* 停止后，重新插回等待队列头部 */
        [self addOperation:operation head:YES];
    }
}

- (void)lockAllData {
    [_waitingQueueLock lockWrite];
    [_runningSetLock lockWrite];
}

- (void)unLockAllData {
    [_runningSetLock unLockWrite];
    [_waitingQueueLock unLockWrite];
}

#pragma mark API
- (void)addOperation:(NNOperation *)operation head:(BOOL)head{
    [_waitingQueueLock lockWrite];
    
    // 重置 operation 运行状态，处理二次调度的情况
    [operation reset];
    
    [operation addObserver:self
                forKeyPath:kNNOperationStateIsStop
                   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                   context:nil];
    
    if (head) {
        [_waitingQueue insertObject:operation atIndex:0];
    }
    else {
        [_waitingQueue addObject:operation];
    }
    
    // Queue 超限，清理尾部的任务
    NSMutableArray *needStopOperations = [NSMutableArray array];
    if (self.maxQueueSize > 0
        && self.waitingQueue.count > self.maxQueueSize) {
        for (NSInteger count = self.waitingQueue.count;
             count > self.maxQueueSize;
             count--) {
            NNOperation *op = [self.waitingQueue objectAtIndex:(count - 1)];
            [needStopOperations addObject:op];
        }
        
        [_waitingQueue removeObjectsInArray:needStopOperations];
    }
    
    [_waitingQueueLock unLockWrite];    
    
    for (NNOperation *op in needStopOperations) {
        [op stop];
        NNLogDebug(kModuleDataTransfer, @"Operation %@ stop sched du to queue size overload.", op);
    }
    
    NNLogDebug(kModuleDataTransfer, @"Operation %@ enqueue %@, head %d", operation, self, head);
    
    [self reSched];
}

- (void)setSuspended:(BOOL)suspend {
    @synchronized(self) {
        if (suspend == _isSuspended) {
            return;
        }

        _isSuspended = suspend;

        if (suspend) {
            [self stopAll];
            NNLogDebug(kModuleDataTransfer, @"Operation queue %@ suspended", self);
        }
        else {
            [self reSched];
            NNLogDebug(kModuleDataTransfer, @"Operation queue %@ resched", self);
        }
    }
}

- (void)stopOneOperation {
    // 两段式 stop，防止 KVO 中死锁
    [_runningSetLock lockRead];
    NSSet *runningSetCopy = [NSSet setWithSet:_runningSet];
    [_runningSetLock unLockRead];
    
    NNOperation *operation = [runningSetCopy anyObject];
    if (operation) {
        [operation stop];
        
        /* 停止后，重新插回等待队列头部 */
        [self addOperation:operation head:YES];
    }
}

- (void)schedOperation:(NNOperation *)operation {
    assert(operation);
    
    [self lockAllData];
    
    // 已经在执行了，直接忽略
    if ([_runningSet containsObject:operation]) {
        [self unLockAllData];
        return;
    }
    
    // 不是在第一个位置，移动任务到队列头，准备被调度
    if ([_waitingQueue indexOfObject:operation] != 0) {
        [_waitingQueue removeObject:operation];
        [_waitingQueue insertObject:operation atIndex:0];
    }
    
    [self unLockAllData];
    
    // 准备停止一个正在运行的任务
    [self stopOneOperation];
}

- (BOOL)isOperationRunning:(NNOperation *)operation {
    assert(operation);
    
    [_runningSetLock lockRead];
    
    BOOL res = NO;
    if ([_runningSet containsObject:operation]) {
        res = YES;
    }
    
    [_runningSetLock unLockRead];
    
    return res;
}

#pragma mark - 缩略图下载优化特殊接口
- (void)clearQueue {
    // 先停止调度，但是继续执行已在运行的任务
    self.isSuspended = YES;
    
    // 清空队列
    [self lockAllData];
    NSArray *waitingQueueCopy = [NSArray arrayWithArray:self.waitingQueue];
    //self.waitingQueue = [[NSMutableArray alloc] init];
    [self unLockAllData];
    
    for (NNOperation *op in waitingQueueCopy) {
        [op stop];
    }
    
    // 重新调度
    [self setSuspended:NO];
}

- (NSArray *)runningOperations {
    [self.runningSetLock lockRead];
    NSArray *resArray =  [NSArray arrayWithArray:self.runningSet.allObjects];
    [self.runningSetLock unLockRead];
    
    return resArray;
}

#pragma mark KVO Callback
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NNOperation *operation = object;
    
    if ([keyPath isEqualToString:kNNOperationStateIsStop]) {
        BOOL new = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        BOOL old = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];

        if (new == YES
            && old == NO) {
            @try {
                [operation removeObserver:self forKeyPath:kNNOperationStateIsStop];
            }
            @catch (NSException *e) {
            }
            
            [self lockAllData];
            
            // 从两个列表里删除任务
            [_runningSet removeObject:operation];
            [_waitingQueue removeObject:operation];
            
            [self unLockAllData];
            
            if ([_delegate respondsToSelector:@selector(NNOperationQueue:operationDidStop:)]) {
                [_delegate NNOperationQueue:self operationDidStop:operation];
            }
            
            NNLogDebug(kModuleDataTransfer, @"Operation %@ stoped", operation);
            
            // 调度下一个任务
            [self reSched];
        }
    }
}
@end