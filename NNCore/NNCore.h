//
//  NNCore.h
//  NNCore
//
//  Created by Rico 9/3/14.
//  Copyright (c) 2014 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NNDeviceManager.h"
#import "NNQueueManager.h"
#import "NNThread.h"

#import "NNLogger.h"
#import "NNNotification.h"

#import "NNDateFormatUtils.h"
#import "NNFileUtils.h"
#import "NNImageUtils.h"
#import "NNCircleRingBuffer.h"
#import "NNLRUCache.h"
#import "NNRWLock.h"

#import "NNTask.h"
#import "NNOperationQueue.h"

#import "NNStorageManager.h"


extern NSString *kLogModuleCore;

@interface NNCore : NSObject

+ (void)setLogFilePath:(NSString *)path;

@end
