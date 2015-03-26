//
//  NNLRUCache.m
//  NNCore
//
//  Created by Rico 13-8-1.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//
#import "NNLRUCache.h"
#import "NNRWLock.h"

#pragma mark - NNLRUCacheEntry
@implementation NNLRUCacheEntry

@end




#pragma mark - NNLRUCache 
@interface NNLRUCache ()

@property (nonatomic, strong) NSMutableDictionary *cacheDict;

@property (nonatomic, strong) NNRWLock *lock;

@end

@implementation NNLRUCache
- (id)initWithCapacity:(NSInteger)capacity {
    self = [super init];
    
    _capacity = capacity;
    _burst = 4;
    
    _cacheDict = [[NSMutableDictionary alloc] init];
    
    _lock = [[NNRWLock alloc] init];
    
    _defaultEntryTTL = -1;
    
    return self;
}


#pragma mark - API
- (void)setCapacity:(NSInteger)capacity {
    _capacity = capacity;
    
    [self evictEntry];
}

- (void)setBurst:(NSInteger)burst {
    _burst = burst;
    
    [self evictEntry];
}

- (void)cacheObject:(id)obj forKey:(id)key {
    assert(obj);
    assert(key);
    
    if (!obj
        || !key) {
        return;
    }
    
    [self.lock lockWrite];

    // 存在两种情况：
    // 1 obj 是 NNLRUCacheEntry 的子类，将obj.key 设置后直接缓存
    // 2 obj 是 NSObject 的子类，需要新建 NNLRUCacheEntry 后置入，才能缓存
    NNLRUCacheEntry *entry = nil;
    if ([obj isKindOfClass:[NNLRUCacheEntry class]]) {
        entry = obj;
        entry.key = key;
        entry.time = time(NULL);
        entry.bornTime = entry.time;
    }
    else {
        entry = [self encapEntryForObject:obj key:key];
    }
    
    // 正式缓存
    [_cacheDict setObject:entry forKey:entry.key];
    
    [self.lock unLockWrite];
    
    // 淘汰
    [self evictEntry];
}


- (id)objectForKey:(id)key {
    assert(key);
    
    [_lock lockRead];
    
    NNLRUCacheEntry *entry = [_cacheDict objectForKey:key];
    
    // 调整 LRU
    time_t now = time(NULL);
    entry.time = now;

    [_lock unLockRead];
    
    if (self.defaultEntryTTL > 0
        && (entry.bornTime - now) > self.defaultEntryTTL) {
        [self removeObjectForKey:key];
        return nil;
    }
    else {
        return entry.value;
    }
}

- (void)removeObjectForKey:(id)key {
    [_lock lockWrite];
    NNLRUCacheEntry *entry = [_cacheDict objectForKey:key];
    if (entry) {
        [_cacheDict removeObjectForKey:key];
    }
    [_lock unLockWrite];
}

- (void)clear {
    [_lock lockWrite];
    [_cacheDict removeAllObjects];
    [_lock unLockWrite];
}

#pragma mark - Internal Functions 
- (NNLRUCacheEntry *)encapEntryForObject:(id)obj key:(id)key {
    NNLRUCacheEntry *entry = [[NNLRUCacheEntry alloc] init];
    entry.key = key;
    entry.value = obj;
    entry.time = time(NULL);
    entry.bornTime = entry.time;
    
    return entry;
}


/**
 * evictEntry
 * @brief 开始淘汰策略，目前淘汰所有超出能力范围的内容
 */
- (void)evictEntry {
    NSInteger burstCount = _capacity + (_capacity / _burst);
    if (_cacheDict.count <= burstCount) {
        return;
    }
    
    [_lock lockWrite];
    
    NSArray *valueArray = [_cacheDict allValues];
    NSArray *sortedArray = [valueArray sortedArrayUsingComparator:^NSComparisonResult(NNLRUCacheEntry *entry1, NNLRUCacheEntry *entry2) {
        if (entry1.time > entry2.time) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    
    NSRange evictRange = {_capacity, sortedArray.count - _capacity};
    NSArray *evictArray = [sortedArray subarrayWithRange:evictRange];
    
    for (NNLRUCacheEntry *entry in evictArray) {
        assert(entry.key);
        
        [_cacheDict removeObjectForKey:entry.key];
        
//        NNlogDebug(kLogModuleCore, @"Evict cache entry for key %@", entry.key);
    }
    
    [_lock unLockWrite];
}

@end
