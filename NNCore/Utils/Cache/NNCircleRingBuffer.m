//
//  NNCircleRing.m
//  NNCore
//
//  Created by Rico 13-12-6.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NNCircleRingBuffer.h"
#import "NNRWLock.h"
#import <libkern/OSAtomic.h>

@interface NNCircleRingBufferObj : NSObject

@property (nonatomic, assign) NNCircleRingBufferObj *next;
@property (nonatomic) NSObject *value;

@property (nonatomic) NNRWLock *objLock;
@end

@implementation NNCircleRingBufferObj

- (id)init {
    self = [super init];
    
    _objLock = [[NNRWLock alloc] init];
    
    return self;
}

- (void)lock {
    [_objLock lockWrite];
}

- (void)unLock {
    [_objLock unLockWrite];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p> value: %@", self, self.value];
}
@end










@interface NNCircleRingBuffer ()

@property (nonatomic) NSMutableArray *bufferObjKeepArray;

@property (nonatomic, assign) NNCircleRingBufferObj *writePoint;
@property (nonatomic, assign) NNCircleRingBufferObj *readPoint;

@property (nonatomic) NNRWLock *readLock;
@property (nonatomic) NNRWLock *writeLock;

@end

@implementation NNCircleRingBuffer
- (id)initWithBufferSize:(NSInteger)size {
    assert(size > 2);
    
    self = [super init];
    
    _readLock = [[NNRWLock alloc] init];
    _writeLock = [[NNRWLock alloc] init];
    
    _bufferObjKeepArray = [[NSMutableArray alloc] init];

    NNCircleRingBufferObj *preObj = nil;
    NNCircleRingBufferObj *first = nil;
    NNCircleRingBufferObj *current = nil;

    for (int i = 0; i < size; i++) {
        current = [[NNCircleRingBufferObj alloc] init];
        [_bufferObjKeepArray addObject:current];
        
        if (preObj) {
            preObj.next = current;
        }
        else {
            first = current;
        }
        
        preObj = current;
    }
    
    current.next = first;

    _writePoint = first;
    _readPoint = first;
    
    return self;
}

- (void)addObject:(NSObject *)aObjcet {
    assert(aObjcet);
    if (!aObjcet) {
        return;
    }
    
    [_writeLock lockWrite];
    __unsafe_unretained NNCircleRingBufferObj *current = _writePoint;
    _writePoint = current.next;
    
    [current lock];
    if (!current.value) {
        OSAtomicIncrement32(&_objCount);
    }
    
    current.value = aObjcet;
    
    //NSLog(@"write value at %@", current);
    [current unLock];
    
    [_writeLock unLockWrite];
}

- (id)nextObject {
    [_readLock lockWrite];
    
    __unsafe_unretained NNCircleRingBufferObj *current = _readPoint;

    [current lock];
    NSObject *resObject = current.value;
    //NSLog(@"read value at %@", current);

    if (resObject) {
        current.value = nil;
        OSAtomicDecrement32(&_objCount);
    }
    
    _readPoint = current.next;
    
    [current unLock];
    
    [_readLock unLockWrite];

    return resObject;
}
@end
