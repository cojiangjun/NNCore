//
//  NNFileUtils.m
//  WeiyunHD
//
//  Created by Rico 12-12-5.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import "NNFileUtils.h"
#import <AVFoundation/AVFoundation.h>

#include <sys/stat.h>
#import <CommonCrypto/CommonDigest.h>
#import "NNLogger.h"

#define CREATE_UUID_BLOCK_SIZE (1024 * 512)

@implementation NNFileUtils

#pragma mark - File Operation
+ (BOOL)createSymblicLinkFrom:(NSString *)fromPath to:(NSString *)toPath {
    NSError *error = nil;
    BOOL successful = [[NSFileManager defaultManager] createSymbolicLinkAtPath:toPath withDestinationPath:fromPath error:&error];
    if (!successful) {
        NSLog(@"Create file link from %@, to %@ failed, reason: %@", fromPath, toPath, error);
        return NO;
    }
    
    return YES;
}

+ (BOOL)createHardLinkFrom:(NSString *)fromPath to:(NSString *)toPath {
    NSError *error = nil;
    [[NSFileManager defaultManager] linkItemAtPath:fromPath toPath:toPath error:&error];
    if (error) {
        NSLog(@"Create file link from %@, to %@ failed, reason: %@", fromPath, toPath, error);
        return NO;
    }
    
    return YES;
}

+ (NSString *)destFileNameOfSymblicFileAtPath:(NSString *)path {
    assert(path);
    
    NSError *error = nil;
    NSString *filePath = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:path error:&error];
    if (!filePath || error) {
        NSLog(@"Get original file path of symblic file %@ failed, reason: %@", path, error);
        return nil;
    }
    
    return [filePath lastPathComponent];
}


+ (BOOL)createDirAtPath:(NSString *)path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            return YES;
        } else {
            [fileManager removeItemAtPath:path error:&error];
        }
    }
    
    BOOL result = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (NO == result) {
        NSLog(@"createDirPath for path:%@ fail, cause:%@ ", path, [error description]);
    }
    
    return result;
}


+ (BOOL)checkFileExists:(NSString *)path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

+ (BOOL)checkDirExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        return isDir;
    }
    
    return NO;
}

+ (BOOL)removeFileAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}

+ (unsigned long long)fileSizeAtPath:(NSString *)path
{
    if (nil == path) {
        return 0;
    }
    
    unsigned long long fileSize = 0;
    
    struct stat st;
    if(stat([path cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        fileSize = st.st_size;
    }
    return fileSize;
}


+ (unsigned long long)getFileSize:(NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    unsigned long long size = 0;
    
    if (path == nil) {
        return 0;
    }
    
    NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:path error:nil];
    if (nil == fileAttributeDic) {
        return 0;
    }

    NSString * fileType = [fileAttributeDic objectForKey:NSFileType];
    if ([fileType isEqualToString:NSFileTypeSymbolicLink]) {
        path = [fileManager destinationOfSymbolicLinkAtPath:path error:nil];
        fileAttributeDic = [fileManager attributesOfItemAtPath:path error:nil];
        fileType = [fileAttributeDic objectForKey:NSFileType];
    }


    BOOL pathIsDir = [fileType isEqualToString:NSFileTypeDirectory];
    if (pathIsDir) {
        NSArray* array = [fileManager subpathsOfDirectoryAtPath:path error:nil];
        for(int i = 0; i<[array count]; i++)
        {
            NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
            
            BOOL isDir;
            if (fullPath && [fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir == NO)
            {
                NSDictionary *subFileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
                size += subFileAttributeDic.fileSize;
            }
        }
    } else {
        return fileAttributeDic.fileSize;
    }
    
    
    //[fileManager release];
    return size;
}

+ (NSString *)md5ForPath:(NSString *)path {
    
    
    NSFileHandle *readerHander = [NSFileHandle fileHandleForReadingAtPath:path];
    NSString *md5ForPath = nil;
    
    if(readerHander != nil) {
        //long long blockSize        = 1024 * 1024 * 20;
        NSUInteger blockSize        = CREATE_UUID_BLOCK_SIZE;
        
        CC_MD5_CTX md5;
        CC_MD5_Init(&md5);
        
        BOOL done = NO;
        
        while (!done) {
            
            NSData *readData = [readerHander readDataOfLength:blockSize];
            if([readData length] == 0) {
                done = YES;
                continue;
            }
            CC_MD5_Update(&md5, [readData bytes], (unsigned)[readData length]);
        }
        
        unsigned char md5_res[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(md5_res, &md5);
        md5ForPath = [[NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                       md5_res[0], md5_res[1],
                       md5_res[2], md5_res[3],
                       md5_res[4], md5_res[5],
                       md5_res[6], md5_res[7],
                       md5_res[8], md5_res[9],
                       md5_res[10], md5_res[11],
                       md5_res[12], md5_res[13],
                       md5_res[14], md5_res[15]] lowercaseString];
        
        [readerHander closeFile];
    }
    
    return md5ForPath;
}


+ (BOOL)mvFileFrom:(NSString *)fromPath to:(NSString *)toPath
{
    if (0 == fromPath.length || 0 == toPath.length) {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if ([fileManager fileExistsAtPath:toPath] == YES) {
        [fileManager removeItemAtPath:toPath error:&error];
    }
    
    BOOL successful = [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];
    
    if (error) {
        NNLogError(kLogModuleCore, @"移动文件(%@)到(%@)失败 : %@", fromPath, toPath, error);
        return NO;
    }
    
    return successful;
}


+ (NSMutableDictionary *)getLocalFilesAtPath:(NSString *)path
{
    BOOL isExist = [NNFileUtils checkFileExists:path];
    if (isExist) {
        
        NSMutableDictionary * filesDict = [NSMutableDictionary dictionary];
        NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path]
                                                                 includingPropertiesForKeys:nil
                                                                                    options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                               errorHandler:nil];
        for (NSURL *theURL in dirEnumerator) {
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            // Ignore files under the _extras directory
            if ([isDirectory boolValue] == YES) {
                [filesDict setObject:@"dir" forKey:fileName];
            } else {
                [filesDict setObject:@"file" forKey:fileName];
            }
        }
        return filesDict;
//        return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    }
    
    return nil;
}

+ (NSString *)getFileExtensionByName:(NSString *)fileName
{

    NSString *extension = nil;

    if ([fileName hasPrefix:@"assets-library"]) {
        NSArray *array = [fileName componentsSeparatedByString:@"ext="];
        if (array.count != 0) {
            extension = [array lastObject];
        }
    }
    else {
        extension = [fileName pathExtension];
    }

    return [extension lowercaseString];
}


+ (NSString *)formatFileSize:(long long)byteSize
{
    NSInteger carryCount = -1;
    double dSize = byteSize;
    NSString * formatStr = nil;
	char *s = "KMGTP";
    

    
    while (fabs(dSize) >= 1024.0 && carryCount < 5) {
        dSize = dSize / 1024;
        carryCount++;
    }
    
    if (carryCount >= 0) {
        formatStr = [NSString stringWithFormat:@"%.1f%cB", dSize, s[carryCount]];
    } else {
        formatStr = [NSString stringWithFormat:@"%.1fB", dSize];
    }

    return formatStr;
}


#pragma mark - File Storage
+ (uint64_t)freeDiskSpace
{
    uint64_t totalFreeSpace = 0;
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *attributesDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    
    if (error) {
        NNLogError(kLogModuleCore, @"Get disk free space error %@", error);
        // 出现问题，就返回一个极大数，防止外部处理异常
        return UINT_MAX;
    }
    if (nil != attributesDic) {
        NSNumber *freeFileSystemSizeInBytes = [attributesDic objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    
    return totalFreeSpace;
}

+ (BOOL)isFreeDiskSpaceEnough:(uint64_t)space
{
    if ([NNFileUtils freeDiskSpace] > (MIN_FREE_DISK_SPACE + space)) {
        return YES;
    }else {
        return NO;
    }
}

@end
