//
//  NNLRUCache.h
//  NNCore
//
//  Created by Rico 13-8-1.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

// NNLRUCacheEntry 有两种使用方式：1 直接使用 2 继承
// 直接使用时，外部不需要做任何操作，内部会将对象作为 NNLRUCacheEntry 的 value 值存储
// 继承时，子类里应该 overrid value 方法，返回 self，这样子类可以直接作为一个缓存对象被缓存，不需要建立 NNLRUCacheEntry 再缓存
@interface NNLRUCacheEntry : NSObject

@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@property (nonatomic, assign) time_t time;
@property (nonatomic, assign) time_t bornTime;
@property (nonatomic, assign) NSInteger ttl;
@end



// 目前只支持按照缓存个数的淘汰策略
@interface NNLRUCache : NSObject

@property (nonatomic, assign) NSInteger capacity; // 缓存能力
@property (nonatomic, assign) NSInteger burst;    // 突发系数
@property (nonatomic, assign) NSInteger defaultEntryTTL; //缓存对象默认生存时间

/**
 * initWithCapacity 
 * @brief 初始化缓存系统，caller 不应该直接调用 init 方法
 * @param capacity 缓存能力
 */
- (id)initWithCapacity:(NSInteger)capacity;

/**
 * cacheObject:forKey
 * @brief 插入缓存对象
 * @param obj 缓存对象，可以是任意 NSObject 子类，或者 NNLRUCacheEntry 子类
 * @param key 缓存键
 */
- (void)cacheObject:(id)obj forKey:(id)key;

/**
 * objectForKey
 * @brief 查询缓存，查询操作会更新对象的缓存访问时间
 * @param key 缓存键
 * @return 缓存对象
 */
- (id)objectForKey:(id)key;

/**
 * removeObjectForKey
 * @brief 从缓存中移除指定对象
 * @param key 缓存键
 */
- (void)removeObjectForKey:(id)key;

- (void)clear;

@end
