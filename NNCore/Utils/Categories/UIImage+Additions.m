//
//  UIImage+Additions.m
//  WeiyunHD
//
//  Created by Rico 13-2-21.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <netinet/in.h>
#import <arpa/inet.h>
#import <Accelerate/Accelerate.h>

#import "UIImage+Additions.h"

@implementation UIImage (Resize)


- (UIImage *)autoResizableImageWithCapInsets:(UIEdgeInsets)capInsets
{
//    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
//        return  [self resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
//    }
    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        return [self resizableImageWithCapInsets:capInsets];
    } else if ([self respondsToSelector:@selector(stretchableImageWithLeftCapWidth:topCapHeight:)]) {
        CGFloat left = capInsets.left;
        CGFloat top = capInsets.top;
        return [self stretchableImageWithLeftCapWidth:left topCapHeight:top];
    }
    
    return self;
}

- (UIImage *)autoResizableImage
{
    CGFloat horizInset = (((NSInteger)self.size.width % 2 == 0) ? (NSInteger)self.size.width/2 - 1 : (NSInteger)self.size.width/2);
    CGFloat vertInset = (((NSInteger)self.size.height % 2 == 0) ? (NSInteger)self.size.height/2 - 1 : (NSInteger)self.size.height/2);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(vertInset, horizInset, vertInset, horizInset);
    return [self autoResizableImageWithCapInsets:capInsets];
}


- (UIImage *)autoResizableImageInSize:(CGSize)size
{
    CGFloat horizInset = (((NSInteger)self.size.width % 2 == 0) ? (NSInteger)self.size.width/2 - 1 : (NSInteger)self.size.width/2);
    CGFloat vertInset = (((NSInteger)self.size.height % 2 == 0) ? (NSInteger)self.size.height/2 - 1 : (NSInteger)self.size.height/2);
    if (size.width / 2 < horizInset) {
        horizInset = size.width/2;
    }

    if (size.height / 2 < vertInset) {
        vertInset = size.height/2;
    }

    UIEdgeInsets capInsets = UIEdgeInsetsMake(vertInset, horizInset, vertInset, horizInset);
    return [self autoResizableImageWithCapInsets:capInsets];
}


- (UIImage *)clipImage:(CGRect)clippedRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], clippedRect);
    UIImage *image   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return image;
}

@end



@implementation UIImage (Alpha)

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation UIImage (Color)


+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{

    UIImage *img = nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;

}

@end




@implementation UIImage (Adjust)


/* vImage kernel */
static int16_t __s_sharpen_kernel_3x3_QQBizAgent[9] = {
	-1, -1, -1,
	-1, 9, -1,
	-1, -1, -1
};
/* vDSP kernel */
static float __f_sharpen_kernel_3x3_QQBizAgent[9] = {
	-1.0f, -1.0f, -1.0f,
	-1.0f, 9.0f, -1.0f,
	-1.0f, -1.0f, -1.0f
};

- (UIImage *)sharpWithSharpness:(CGFloat)sharpness
{
    return sharpenWithBias_QQBizAgent(self, 0);
}

static  UIImage * sharpenWithBias_QQBizAgent(UIImage *srcImg,NSInteger bias)
{
    /// Create an ARGB bitmap context
	const size_t width = srcImg.size.width;
	const size_t height = srcImg.size.height;
	const size_t bytesPerRow = width * 4;
    CGColorSpaceRef cgColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext =CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, bytesPerRow, cgColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(cgColorSpace);
	if (!bmContext) {
		return nil;
    }

	/// Draw the image in the bitmap context
	CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, srcImg.CGImage);

	/// Grab the image raw data
	UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
	if (!data)
	{
		CGContextRelease(bmContext);
		return nil;
	}


    
	/// vImage (iOS 5)
	if ((&vImageConvolveWithBias_ARGB8888))
	{
		const size_t n = sizeof(UInt8) * width * height * 4;
		void* outt = malloc(n);
		vImage_Buffer src = {data, height, width, bytesPerRow};
		vImage_Buffer dest = {outt, height, width, bytesPerRow};
		vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_sharpen_kernel_3x3_QQBizAgent, 3, 3, 1/*divisor*/, (int)bias, NULL, kvImageCopyInPlace);

		memcpy(data, outt, n);

		free(outt);
	}
    else
	{
		const size_t pixelsCount = width * height;
		const size_t n = sizeof(float) * pixelsCount;
		float* dataAsFloat = malloc(n);
		float* resultAsFloat = malloc(n);
		float min = (float)0, max = (float)255;

		/// Red components
		vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
		vDSP_f3x3(dataAsFloat, height, width, __f_sharpen_kernel_3x3_QQBizAgent, resultAsFloat);
		vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
		vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);

		/// Green components
		vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
		vDSP_f3x3(dataAsFloat, height, width, __f_sharpen_kernel_3x3_QQBizAgent, resultAsFloat);
		vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
		vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);

		/// Blue components
		vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
		vDSP_f3x3(dataAsFloat, height, width, __f_sharpen_kernel_3x3_QQBizAgent, resultAsFloat);
		vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
		vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);

		free(dataAsFloat);
		free(resultAsFloat);
	}

	CGImageRef sharpenedImageRef = CGBitmapContextCreateImage(bmContext);
	UIImage* sharpened = [UIImage imageWithCGImage:sharpenedImageRef];

	/// Cleanup
	CGImageRelease(sharpenedImageRef);
	CGContextRelease(bmContext);

	return sharpened;

}

@end


