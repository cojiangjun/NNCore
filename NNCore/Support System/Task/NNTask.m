//
//  NNTask.m
//  WeiyunHD
//
//  Created by Rcio on 13-1-10.
//  Copyright (c) 2013年 Rcio. All rights reserved.
//

#import "NNTask.h"

@implementation NNTask
#pragma mark - Public
- (NSString *)taskID {
    return @"";
}

- (NSUInteger)maxRetryCount {
    return 0;
}

- (BOOL)needRetry {
    if (_needRetry == NO) {
        return NO;
    }
    
    return _retryCount < [self maxRetryCount];
}

- (void)execute
{
}

- (void)taskWillExcute {
}

- (void)taskDidFinished {
    [self stop];
}

- (void)taskDidFailed {
    [self stop];
}

- (void)taskDidCanceled {
    [self stop];
}

- (void)start {
    [self taskWillExcute];

    [self execute];
}

- (void)startTask {
}

- (void)startPreemptionTask {
    [self startTask];
}

- (void)mergeTask:(NNTask *)task {
    
}
@end
