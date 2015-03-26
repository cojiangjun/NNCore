//
//  NNStorageManager.h
//  NNCore
//
//  Created by Rico on 14-4-28.
//  Copyright (c) 2014年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNStorageManager : NSObject
@property (nonatomic, copy, readonly) NSString *rootPath;

+ (NNStorageManager *)instance;
- (NSString *)fullPath:(NSString *)relativePath;
@end
