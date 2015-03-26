//
//  NNTask.h
//  WeiyunHD
//
//  Created by Rcio on 13-1-10.
//  Copyright (c) 2013年 Rcio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNOperation.h"

typedef enum {
    NNTaskPriorityDefault,       // 默认排入对列尾部等待调度
    NNTaskPriorityASAP,          // 排入队列头部优先调度
    NNTaskPriorityImmediately    // 抢占调度，插入队列头，停止当前执行的任务
} NNTaskPriority;

extern NSString *kIsFinished;
extern NSString *kIsCancelled;
extern NSString *kIsExecuting;

@interface NNTask : NNOperation

@property (nonatomic, strong) NSNumber *                db_id;              //任务的id，由数据库自动生产，是任务在本地的唯一标示
@property (nonatomic, assign) NNTaskPriority         priority;           //任务的优先级
@property (nonatomic, assign) int                       ret_code;           //任务的返回码
@property (nonatomic, strong) NSString *                task_ctime;         //任务的创建时间

@property (nonatomic, assign) NSUInteger retryCount;
@property (nonatomic, assign) BOOL needRetry;

//- (BOOL)canMultiExecute;
- (NSString *)taskID;
- (NSUInteger)maxRetryCount;
- (BOOL)needRetry;

/*
 * 任务执行代码
 */
- (void)execute;


- (void)taskWillExcute;
- (void)taskDidFinished;
- (void)taskDidFailed;
- (void)taskDidCanceled;

- (void)startTask;
- (void)startPreemptionTask;

/**
 * mergeTask
 * @brief 合并任务数据。当任务已经入队执行，试图插入另一个同样 ID 的任务的时候，默认会根据状态，选择执行两个中的一个。
 * 当某些情况下，两个相同 ID 的任务携带不同的信息，这时可能希望对两个任务的数据进行合并。子类可以通过继承该方法，实现数据复制的行为
 * 注意，该操作是有方向性的
 */
- (void)mergeTask:(NNTask *)task;
@end
