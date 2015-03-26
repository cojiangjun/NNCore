//
//  NNCore.m
//  NNCore
//
//  Created by Rico 9/3/14.
//  Copyright (c) 2014 Rcio Wang. All rights reserved.
//

#import "NNCore.h"

NSString *kLogModuleCore = @"NNCore";


@implementation NNCore

+ (void)setLogFilePath:(NSString *)path {
    assert(path);
    
    [[NNLogger sharedLogger] setLogFilePath:path];
}
@end
