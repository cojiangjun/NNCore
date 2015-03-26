//
//  NNRWLock.h
//  NNCore
//
//  Created by Rico 13-7-17.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNRWLock : NSObject

- (void)lockRead;
- (BOOL)tryLockRead;
- (void)unLockRead;

- (void)lockWrite;
- (BOOL)tryLockWrite;
- (void)unLockWrite;

@end
