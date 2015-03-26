//
//  NNFileUtils.h
//  WeiyunHD
//
//  Created by Rico 12-12-5.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MIN_FREE_DISK_SPACE (1024 * 1024 * 64)   //最小空余64M，防止系统清空缓存文件。

typedef enum
{
    kNNSmallSizeMode,
    kNNBigSizeMode,
} NNSizeMode;


@interface NNFileUtils : NSObject


#pragma mark - File Operation
+ (BOOL)createSymblicLinkFrom:(NSString *)fromPath to:(NSString *)toPath;
+ (BOOL)createHardLinkFrom:(NSString *)fromPath to:(NSString *)toPath;
+ (BOOL)createDirAtPath:(NSString *)path;
+ (BOOL)checkFileExists:(NSString *)path;
+ (BOOL)checkDirExists:(NSString *)path;
+ (BOOL)removeFileAtPath:(NSString *)path;
+ (unsigned long long)fileSizeAtPath:(NSString *)path;   //该方法效率更高
+ (unsigned long long)getFileSize:(NSString*)path;
+ (NSString *)md5ForPath:(NSString *)path;
+ (BOOL)mvFileFrom:(NSString *)fromPath to:(NSString *)toPath;
+ (NSMutableDictionary *)getLocalFilesAtPath:(NSString *)path;


+ (NSString *)getFileExtensionByName:(NSString *)fileName;

/*      //NNFileIconUtils类中有一样的方法
+ (UIImage *)getFileIconOfName:(NSString *)fileName;
+ (UIImage *)getFileIconOfName:(NSString *)fileName withSizeMode:(NNSizeMode)sizeMode;
*/
/*
 * 对重复的duplicateName进行重命名，不能与conflictNames中的名称重名
 */

/**
 * destFileNameOfSymblicFileAtPath
 * @brief 根据链接文件路径，得到被链接的原始文件名
 * @param path 链接文件路径
 * @return 原始文件文件名，不含路径信息
 */
+ (NSString *)destFileNameOfSymblicFileAtPath:(NSString *)path;


#pragma mark - File Storage
+ (uint64_t)freeDiskSpace;

@end
