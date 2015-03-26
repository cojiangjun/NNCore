//
//  NSURL+Asset.m
//  WeiyunHD
//
//  Created by Rico 13-4-18.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import "NSURL+Asset.h"

@implementation NSURL (Asset)

- (NSString *) assetExtension {
    if([self.scheme isEqualToString:@"assets-library"]) {
        NSString *filePath = [self absoluteString];
        NSString *extension = [[filePath componentsSeparatedByString:@"&ext="] lastObject];
        
        return extension;
    }
    return nil;
}


- (BOOL)isAssetURL
{
    return [self.scheme isEqualToString:@"assets-library"];
}


@end
