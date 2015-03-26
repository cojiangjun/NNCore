//
//  NNRWLock.m
//  NNCore
//
//  Created by Rico 13-7-17.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NNRWLock.h"
#import <sched.h>
#import <libkern/OSAtomic.h>

#define LOCK_FLAG_UNLOCK 0
#define LOCK_FLAG_WRITE  10000

@interface NNRWLock ()

@property (nonatomic, assign) int lockCount;

@end

@implementation NNRWLock

- (void)lockRead {
    while ([self tryLockRead] == NO) {
        sched_yield();
    }
}

- (BOOL)tryLockRead {
    int tryCount = 0;
    do {
        int lCount = _lockCount;
        if (lCount < LOCK_FLAG_WRITE) {
            if (OSAtomicCompareAndSwapInt(lCount, lCount + 1, &_lockCount)) {
                return YES;
            }
        }
        
        tryCount++;
    } while (tryCount < 3);
    
    return NO;
}

- (void)unLockRead {
    do {
        int lCount = _lockCount;
        if (lCount > 0) {
            if (OSAtomicCompareAndSwapInt(lCount, lCount - 1, &_lockCount)) {
                return;
            }
        }
    } while (1);
}

- (void)lockWrite {
    do {
        int lCount = _lockCount;
        if (lCount < LOCK_FLAG_WRITE) {
            if (OSAtomicCompareAndSwapInt(lCount, lCount + LOCK_FLAG_WRITE, &_lockCount)) {
                while (1) {
                    if (_lockCount == LOCK_FLAG_WRITE) {
                        return;
                    }
                    
                    sched_yield();
                }
            }
        }
        
        sched_yield();
    } while (1);
}

- (BOOL)tryLockWrite {
    int tryCount = 0;
    do {
        int lCount = _lockCount;
        if (lCount == LOCK_FLAG_UNLOCK) {
            if (OSAtomicCompareAndSwapInt(lCount, lCount + LOCK_FLAG_WRITE, &_lockCount)) {
                return YES;
            }
        }
        
        tryCount++;
    } while (tryCount < 3);
    
    return NO;
}

- (void)unLockWrite {
    do {
        int lCount = _lockCount;
        assert(lCount >= LOCK_FLAG_WRITE);
        
        if (lCount < LOCK_FLAG_WRITE) {
            return;
        }
        
        if (OSAtomicCompareAndSwapInt(lCount, lCount - LOCK_FLAG_WRITE, &_lockCount)) {
            return;
        }

    } while (1);
}

@end
