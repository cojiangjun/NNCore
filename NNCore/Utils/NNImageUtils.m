//
//  NNImageUtils.m
//  WeiyunHD
//
//  Created by Rico 12-12-12.
//  Copyright (c) 2012年 Rcio Wang. All rights reserved.
//

#include <ImageIO/ImageIO.h>

#import "NNImageUtils.h"
#import "NNFileUtils.h"

#import <ImageIO/CGImageDestination.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "NNLogger.h"

//动态图片最大展示帧数
static const int kMaxNumberOfDynamicImageFrame = 480;


#define RESIZE_IMAGE_ERROR_DOMAIN   @"ResizeImage"

//修改图片大小的错误码
typedef enum
{
    kSourcePathError = 301,
    kCreateImageSourceError,
    kPropertiesError,
    kGetThumbError,
    kSizeError,
} ResizeImageErrorCode;

@implementation NNImageUtils


#pragma mark - Get Image
+ (NSArray *)getAnimationImagesAtPath:(NSString *)imagePath {
    //缓存动画，解决重复读取，暂时缓存一个图
    static NSMutableDictionary *cacheFrames = nil;
    
    if (nil == cacheFrames) {
        cacheFrames = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    NSMutableArray *images = [cacheFrames objectForKey:imagePath];
    if (nil != images) {
        return images;
    }
    
    NSURL *imageUrl = [[NSURL alloc] initFileURLWithPath:imagePath];
    
    if (nil == imageUrl) {
        return nil;
    }
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
    if (NULL == imageSourceRef) {
        return nil;
    }
    
    size_t imagesCount = CGImageSourceGetCount(imageSourceRef);
    
    if (imagesCount <= 1) {
        CFRelease(imageSourceRef);
        return nil;
    }
    
    
    float frameSpaceRate = 1;
    if (imagesCount > kMaxNumberOfDynamicImageFrame) {
        //控制帧数，大于最大帧数时，疏漏选择帧
        frameSpaceRate = (float)imagesCount / kMaxNumberOfDynamicImageFrame;
    }
    
    images = [NSMutableArray arrayWithCapacity:imagesCount];
    
    for(float i = 0; i < imagesCount; i += frameSpaceRate) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, (size_t)i, NULL);
        [images addObject:[UIImage imageWithCGImage:imageRef]];
        CFRelease(imageRef);
    }
    
    
    CFRelease(imageSourceRef);
    
    [cacheFrames removeAllObjects];
    [cacheFrames setObject:images forKey:imagePath];
    
    return images;
}




#pragma mark - Create Thumbnail
//通过ImageIO去生成缩略图
+ (UIImage *)createThumbnailFromImageURL:(NSURL *)srcUrl withMaxPixelSize:(int)scalePixel error:(NSError **)error
{
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)srcUrl, NULL);
    
    if (NULL == imageSourceRef) {
        if (NULL != error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Create CGImageSourceRef Failed" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:RESIZE_IMAGE_ERROR_DOMAIN code:kCreateImageSourceError userInfo:details];
        }
        return nil;
    }
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
    if (NULL == imageProperties) {
        if (NULL != error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Get CGImageSource Properties Failed" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:RESIZE_IMAGE_ERROR_DOMAIN code:kPropertiesError userInfo:details];
        }
        CFRelease(imageSourceRef);
        return nil;
    }
    
    
    CFNumberRef pixelWidthRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
    CFNumberRef pixelHeightRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
    CGFloat pixelWidth = [(__bridge NSNumber *)pixelWidthRef floatValue];
    CGFloat pixelHeight = [(__bridge NSNumber *)pixelHeightRef floatValue];
    CFRelease(imageProperties);
    
    //判断尺寸
    if (NULL != error && scalePixel >= MAX(pixelWidth, pixelHeight)) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Scale size is Bigger than source size" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:RESIZE_IMAGE_ERROR_DOMAIN code:kSizeError userInfo:details];
        
        CFRelease(imageSourceRef);
        return nil;
    }
    
    CGFloat widthScaleRate = scalePixel / pixelWidth;
    CGFloat heightScaleRate = scalePixel / pixelHeight;
    CGFloat maxScaleRate = MAX(widthScaleRate, heightScaleRate);
    scalePixel = maxScaleRate * MAX(pixelWidth, pixelHeight);
    
    CGImageRef thumbnailImageRef = NULL;
    
    @autoreleasepool {
        NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                          (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                          (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways,
                                          [NSNumber numberWithInt:scalePixel], (id)kCGImageSourceThumbnailMaxPixelSize,
                                          nil];
        thumbnailImageRef = CGImageSourceCreateThumbnailAtIndex(imageSourceRef, 0, (__bridge CFDictionaryRef)thumbnailOptions);
    }
    
    
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(imageSourceRef);
    
    if (NULL == thumbnailImageRef) {
        if (NULL != error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Cet thumbnail failed" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:RESIZE_IMAGE_ERROR_DOMAIN code:kGetThumbError userInfo:details];
        }
        
        return nil;
    }
    
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    CFRelease(thumbnailImageRef);
    
    return thumbnail;
}




+ (UIImage *)createThumbnailFromImagePath:(NSString *)path withMaxPixelSize:(int)scalePixel error:(NSError **)error
{
    NSURL *srcUrl = [NSURL fileURLWithPath:path];
    if (nil == srcUrl) {
        return nil;
    }
    
    return [NNImageUtils createThumbnailFromImageURL:srcUrl withMaxPixelSize:scalePixel error:error];
}


//批量生成缩略图
+ (NSArray *)createThumbsFromPath:(NSString *)path ofScaleSizes:(NSArray *)scaleSizes
{
    NSURL *srcUrl = [NSURL fileURLWithPath:path];
    if (nil == srcUrl) {
        return nil;
    }
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)srcUrl, NULL);
    if (NULL == imageSourceRef) {
        return nil;
    }
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
    if (NULL == imageProperties) {
        CFRelease(imageSourceRef);
        return nil;
    }
    
    CFNumberRef pixelWidthRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
    CFNumberRef pixelHeightRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
    CGFloat pixelWidth = [(__bridge NSNumber *)pixelWidthRef floatValue];
    CGFloat pixelHeight = [(__bridge NSNumber *)pixelHeightRef floatValue];
    CFRelease(imageProperties);
    
    
    NSInteger thumbsCount = [scaleSizes count];
    NSMutableArray *thumbs = [NSMutableArray arrayWithCapacity:thumbsCount];
    for (int i = 0; i < thumbsCount; i++) {
        
        CGSize size = [[scaleSizes objectAtIndex:i] CGSizeValue];
        
        //生产的图片需最小满足size，如size为(120, 120), 原图为(240, 360)，则scalePixel为180，生成的图片为(120, 180)
        CGFloat widthScaleRate = size.width / pixelWidth;
        CGFloat heightScaleRate = size.height / pixelHeight;
        CGFloat maxScaleRate = MAX(widthScaleRate, heightScaleRate);
        int scalePixel = maxScaleRate * MAX(pixelWidth, pixelHeight);
        
        CGImageRef thumbnailImageRef = NULL;
        
        @autoreleasepool {
            NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                              (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                              (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways,
                                              [NSNumber numberWithInt:scalePixel], (id)kCGImageSourceThumbnailMaxPixelSize,
                                              nil];
            thumbnailImageRef = CGImageSourceCreateThumbnailAtIndex(imageSourceRef, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        }
        
        if (NULL == thumbnailImageRef) {
            CFRelease(imageSourceRef);
            return nil;
        }
        
        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        CFRelease(thumbnailImageRef);
        
        [thumbs addObject:thumbnail];

    }
    
    CFRelease(imageSourceRef);
    
    return [NSArray arrayWithArray:thumbs];
}



+ (NSArray *)createThumbsFromPath:(NSString *)sourcePath ofSizes:(NSArray *)sizes
{
    /*
    if (nil == sourcePath || [sizes count] <= 0) {
        return nil;
    }
    
    if ([sourcePath hasPrefix:@"assets-library://"]) {
        
        NSURL *sourceURL = [NSURL URLWithString:sourcePath];
        ALAsset *asset = [NNAssetUtils assetForURL:sourceURL];
        
        NSInteger thumbsCount = [sizes count];
        NSMutableArray *thumbs = [NSMutableArray arrayWithCapacity:thumbsCount];
        UIImage *thumb = nil;
        
        for (NSInteger i = 0; i < thumbsCount; i++) {
            CGSize size = [[sizes objectAtIndex:i] CGSizeValue];
            
            if (CGSizeCloseToSize(size, kScaleSmallThumbSize) || CGSizeCloseToSize(size, kScaleMediumThumbSize)) {
                CGImageRef thumbRef = [asset thumbnail];
                thumb = [UIImage imageWithCGImage:thumbRef];
            } else if (CGSizeCloseToSize(size, kScaleBigThumbSize)){
                ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
                CGImageRef thumbRef = [defaultRep fullScreenImage];
                
                if (SYSTEM_VERSION_GREATER_THAN(@"5.0")) {
                    thumb = [UIImage imageWithCGImage:thumbRef scale:[defaultRep scale] orientation:0];
                } else  {
                    thumb = [UIImage imageWithCGImage:thumbRef scale:[defaultRep scale] orientation:(UIImageOrientation)[defaultRep orientation]];
                }
            } else {
                //CGImageSourceRef无法加载ALAsset的URL
//                thumb = [NNImageUtils createThumbnailFromImageURL:sourceURL withMaxPixelSize:(int)MAX(size.width, size.height) error:nil];
            }
            
            if (thumb == nil) {
                return nil;
            }
            [thumbs addObject:thumb];
        }
        
        return thumbs;
        
    } else {
        return [NNImageUtils createThumbsFromPath:sourcePath ofScaleSizes:sizes];
    }
     */
    return nil;
}


+ (UIImage *)createThumbFromPath:(NSString *)sourcePath ofSize:(CGSize)size
{
    NSValue *sizeValue = [NSValue valueWithCGSize:size];
    if (nil == sizeValue) {
        return nil;
    }
    
    NSArray *sizes = [NSArray arrayWithObject:sizeValue];
    NSArray *thumbs = [self createThumbsFromPath:sourcePath ofScaleSizes:sizes];

    if ([thumbs count] <= 0) {
        return nil;
    }
    
    return [thumbs objectAtIndex:0];
}



#pragma mark - Save Image
+ (BOOL)saveImage:(UIImage *)image toPath:(NSString *)path
{
    if (image == nil || path == nil) {
        return NO;
    }
    
    @try {
        NSData *imageData = nil;
//        NSString *ext = [path pathExtension];
//        if ([ext isEqualToString:@"png"]) {
//            imageData = UIImagePNGRepresentation(image);
//        } else {
            imageData = UIImageJPEGRepresentation(image, 0.75);
//        }
        
        NSLog(@"thumb is wrote to : %@", path);
        if ((imageData == nil) || ([imageData length] <= 0)) {
            return NO;
        }
        
        NSString *fatherDir = [path stringByDeletingLastPathComponent];
        if ([NNFileUtils createDirAtPath:fatherDir]) {
            return [imageData writeToFile:path atomically:YES];
        }

    }
    @catch (NSException *exception) {
        return NO;
    }
}


+ (NSString *)getFullAppTagWithTag:(NSString *)tag
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    if (nil == tag) {
        return version;
    }
    
    return [tag stringByAppendingFormat:@" %@", version];
}


+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


+ (BOOL)isValidImage:(NSString *)filePath
{
    @autoreleasepool {
        NSURL *fileUrl = nil;
        if ([filePath hasPrefix:@"assets-library://"]) {
//            ALAsset *asset = [[NNImagePickerViewController sharedController] getAssetsByPath:filePath];
//            ALAssetRepresentation *representation = [asset defaultRepresentation];
//            fileUrl = representation.url;
        }  else {
            if (nil == filePath) {
                return YES;
            }
            
            NSString *prefix = @"file://";
            
            if ([filePath hasPrefix:prefix]) {
                filePath = [filePath substringFromIndex:prefix.length];
            }
            
            fileUrl = [NSURL fileURLWithPath:filePath];
        }
        
        CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)fileUrl, NULL);
        
        if (NULL == imageSourceRef) {
            NNLogInfo(kLogModuleCore, @"Create CGImageSourceRef of %@ failed!", fileUrl);
            return NO;
        }
        
        
        CGImageSourceStatus status = CGImageSourceGetStatus(imageSourceRef);
        CFRelease(imageSourceRef);
        
        //通过状态判断图片合法
        if (status <= kCGImageStatusReadingHeader) {
            return NO;
        }
        
        //    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        //    if (NULL == imageProperties) {
        //        NNLog(@"CGImageSourceCopyPropertiesAtIndex of %@ failed!", fileUrl);
        //        CFRelease(imageSourceRef);
        //        return NO;
        //    }
        //
        //    CFRelease(imageProperties);
        
        return YES;
    }
}


+ (CGSize)imageSizeAtPath:(NSString *)path
{
    NSURL *srcUrl = [NSURL fileURLWithPath:path];
    if (nil == srcUrl) {
        return CGSizeZero;
    }
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)srcUrl, NULL);
    if (NULL == imageSourceRef) {
        return CGSizeZero;
    }
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
    if (NULL == imageProperties) {
        CFRelease(imageSourceRef);
        return CGSizeZero;
    }
    
    CFNumberRef pixelWidthRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
    CFNumberRef pixelHeightRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
    CGFloat pixelWidth = [(__bridge NSNumber *)pixelWidthRef floatValue];
    CGFloat pixelHeight = [(__bridge NSNumber *)pixelHeightRef floatValue];
    CGSize size = CGSizeMake(pixelWidth, pixelHeight);
    CFRelease(imageProperties);
    CFRelease(imageSourceRef);
    
    return size;

}


#pragma mark - Animated Image

//获取动态图片的帧
+ (NSArray *)getAnimatedImagesByPath:(NSString *)imagePath
{
    //缓存动画，解决重复读取，暂时缓存一个图
//    static NSMutableDictionary *cacheFrames = nil;
//    if (nil == cacheFrames) {
//        cacheFrames = [[NSMutableDictionary alloc] initWithCapacity:1];
//    }
//    NSMutableArray *images = [cacheFrames objectForKey:imagePath];
//    if (nil != images) {
//        return images;
//    }

    NSMutableArray *images = nil;
    NSURL *imageUrl = [[NSURL alloc] initFileURLWithPath:imagePath];

    if (nil == imageUrl) {
        return nil;
    }

    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
    if (NULL == imageSourceRef) {
        return nil;
    }

    size_t imagesCount = CGImageSourceGetCount(imageSourceRef);

    if (imagesCount <= 1) {
        CFRelease(imageSourceRef);
        return nil;
    }


    float frameSpaceRate = 1;
    if (imagesCount > kMaxNumberOfDynamicImageFrame) {
        //控制帧数，大于最大帧数时，疏漏选择帧
        frameSpaceRate = (float)imagesCount / kMaxNumberOfDynamicImageFrame;
    }

    images = [NSMutableArray arrayWithCapacity:imagesCount];

    for(float i = 0; i < imagesCount; i += frameSpaceRate) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, (size_t)i, NULL);
        [images addObject:[UIImage imageWithCGImage:imageRef]];
        CFRelease(imageRef);
    }


    CFRelease(imageSourceRef);

//    [cacheFrames removeAllObjects];
//    [cacheFrames setObject:images forKey:imagePath];

    return images;
}



@end
