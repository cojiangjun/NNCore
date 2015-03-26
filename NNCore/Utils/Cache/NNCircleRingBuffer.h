//
//  NNCircleRing.h
//  NNCore
//
//  Created by Rico 13-12-6.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNCircleRingBuffer : NSObject
@property (nonatomic) int objCount;

- (id)initWithBufferSize:(NSInteger)size;

- (void)addObject:(NSObject *)aObjcet;
- (id)nextObject;

@end
