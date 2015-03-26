//
//  NNImageUtils.h
//  WeiyunHD
//
//  Created by Rico 12-12-12.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ALAsset;

@interface NNImageUtils : NSObject


#pragma mark - Get Image
+ (NSArray *)getAnimationImagesAtPath:(NSString *)imagePath;



#pragma mark - Create Thumbnail
//生成最长边为scalePixel的缩略图
+ (UIImage *)createThumbnailFromImageURL:(NSURL *)srcUrl withMaxPixelSize:(int)scalePixel error:(NSError **)error;
+ (UIImage *)createThumbnailFromImagePath:(NSString *)path withMaxPixelSize:(int)scalePixel error:(NSError **)error;

+ (NSArray *)createThumbsFromPath:(NSString *)sourcePath ofSizes:(NSArray *)sizes;
+ (UIImage *)createThumbFromPath:(NSString *)sourcePath ofSize:(CGSize)size;


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;


+ (BOOL)isValidImage:(NSString *)filePath;

+ (CGSize)imageSizeAtPath:(NSString *)path;

#pragma mark - Animated Image
//获取动态图片的帧
+ (NSArray *)getAnimatedImagesByPath:(NSString *)imagePath;


@end
