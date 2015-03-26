//
// Created by Rico 13-5-9.
//
// Copyright (c) 2013年 Rcio Wang. All rights reserved.
//


#import "NNThread.h"

@interface NNThread () {
    NSRunLoop *_runLoop;
}
@property (nonatomic, strong) NSCondition *condition;
@end

@implementation NNThread

+ (NNThread*)shareInstance
{
    static NNThread *_shareThread = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareThread = [[[self class] alloc] init];
        [_shareThread setName:@"_NNShareThread"];
        [_shareThread start];
    });
    
    return _shareThread;
}

- (NSRunLoop *)runLoop {
    if (_runLoop == nil) {
        [self.condition lock];
        while (_runLoop == nil) {
            [self.condition wait];
        }
        [self.condition unlock];
    }
    return _runLoop;
}

- (void)start {
    self.condition = [[NSCondition alloc] init];

    [super start];
}

- (void)onTimer {
}

- (void)main {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [self.condition lock];
    _runLoop = runLoop;
    [self.condition signal];
    [self.condition unlock];

    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(onTimer) userInfo:nil repeats:YES];

    while (! [self isCancelled]) {
        @autoreleasepool {
            [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
        }
    }
}

@end