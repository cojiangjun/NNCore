//
//  NNStorageManager.m
//  NNCore
//
//  Created by Rico on 14-4-28.
//  Copyright (c) 2014年 Rcio Wang. All rights reserved.
//

#import "NNStorageManager.h"
#import <sys/xattr.h>

@implementation NNStorageManager

+ (NNStorageManager *)instance
{
    static NNStorageManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    NSString *APPName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ([paths count] >0) {
        NSString * libaryPath = [paths objectAtIndex:0];
        _rootPath = [libaryPath stringByAppendingPathComponent:APPName];
    }
    
    [NNFileUtils createDirAtPath:_rootPath];
    
    [self preventBeingBackupToiCloud];
    
    return self;
}

- (NSString *)fullPath:(NSString *)relativePath {
    return [NSString stringWithFormat:@"%@/%@", _rootPath, relativePath];
}

#pragma mark - Internal Function
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    
    // First try and remove the extended attribute if it is present
    ssize_t result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
    if (result != -1) {
        // The attribute exists, we need to remove it
        int removeResult = removexattr(filePath, attrName, 0);
        if (removeResult == 0) {
            NNLogDebug(kLogModuleCore, @"Removed extended attribute on file %@", URL);
        }
    }
    
    // Set the new key
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if(!success){
        NNLogDebug(kLogModuleCore, @"Error excluding %@ from backup %@", [URL path], error);
    }
    return success;
}

- (void)preventBeingBackupToiCloud
{
    NSString * libaryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL * libraryPathURL = [NSURL fileURLWithPath:libaryPath];
    [self addSkipBackupAttributeToItemAtURL:libraryPathURL];
    
    
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL * documentsPathURL = [NSURL fileURLWithPath:documentsPath];
    [self addSkipBackupAttributeToItemAtURL:documentsPathURL];
}

@end
