//
//  NNOperation.m
//  WeiyunModel
//
//  Created by Rico on 13-7-11.
//  Copyright (c) 2013年 Rcio. All rights reserved.
//

#import "NNOperation.h"

@interface NNOperation ()
@end

@implementation NNOperation
- (void)start {
    // wilsonwan, 2013-07-31, 这里需要将isStopped置为NO吗? 因为可能会stop后再次start
    // rciowang, 这里不用，重新添加进队列的时候处理
    // wilsonwan, 2013-11-15, 收到 :)
}

- (void)stop {
    self.isCanceled = YES;
    self.isStopped = YES;
}

- (void)cancel {
    self.isCanceled = YES;
}

- (void)reset {
    self.isCanceled = NO;
    self.isStopped = NO;
}
@end