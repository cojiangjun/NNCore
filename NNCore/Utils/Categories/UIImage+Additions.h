//
//  UIImage+Additions.h
//  WeiyunHD
//
//  Created by Rico 13-2-21.
//  Copyright (c) 2013年 Rcio Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)


/*
 * resizableImageWithCapInsets: 兼容 stretchableImageWithLeftCapWidth:topCapHeight:
 */
- (UIImage *)autoResizableImageWithCapInsets:(UIEdgeInsets)capInsets;

/*
 * 从图的中间进行resizableImageWithCapInsets
 */
- (UIImage *)autoResizableImage;


/*
 * 在不超过size的情况下，从图的中间进行resizableImageWithCapInsets
 */
- (UIImage *)autoResizableImageInSize:(CGSize)size;

/**
 * 裁剪照片
 * @param clippedRect 裁剪的矩形区域
 * @return 裁剪后的照片
 */
- (UIImage *)clipImage:(CGRect)clippedRect;

@end


@interface UIImage (Cache)
/*
 * 从缓存中读取数据
 */
+ (UIImage *)imageWithCachePath:(NSString *)path;

@end


@interface UIImage (Alpha)
/*
 * 改变UIImage的透明度
 */
- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

@end


@interface UIImage (Color)

/**
 * @brief 根据颜色值和尺寸生成照片
 * @param color 颜色值
 * @param size 生成image的尺寸
 * @return 生成的image对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end



@interface UIImage (Adjust)

- (UIImage *)sharpWithSharpness:(CGFloat)sharpness;

@end

