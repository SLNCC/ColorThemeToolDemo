//
//  SMColorThemeTool.m
//  Keyboard
//
//  Created by a on 2021/4/6.
//  Copyright © 2021 Joedd. All rights reserved.
//

#import "SMColorThemeTool.h"

@implementation SMColorThemeTool

//获取图片的主色调
+ (UIColor *)mostColor:(UIImage *)sourceImage scaleRect:(CGRect)rect partRect:(CGRect)rect2 {
    UIImage* cropImg = [self cropImage:sourceImage scaleRect:rect partRect:rect2];
    if (cropImg == nil) {
        return nil;
    }
   
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    CGSize thumbSize = cropImg.size;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,thumbSize.width, thumbSize.height, 8, thumbSize.width*4, colorSpace, bitmapInfo);
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, cropImg.CGImage);
    CGColorSpaceRelease(colorSpace);
    //取每个点的像素的值
    unsigned char* data = CGBitmapContextGetData(context);
    if (data == NULL) {
        return  nil;
    }
    NSCountedSet* cls = [NSCountedSet setWithCapacity:thumbSize.width * thumbSize.height];
    for (int x = 0; x < thumbSize.width; x++) {
        for (int y = 0; y < thumbSize.height; y++) {
            int offset = 4 * x*y;
            int r = data[offset];
            int g = data[offset+1];
            int b = data[offset+2];
            int a = data[offset+3];
            if (a > 0) { //去除透明
                if (r == 255 && g == 255 && b == 255) {//去除白色
                }else{
                    NSArray* clr = @[@(r),@(g),@(b),@(a)];
                    [cls addObject:clr];
                }
            }
        }
    }
    CGContextRelease(context);
    
    //找到出现次数最多的那个颜色
    NSEnumerator* enumertator  = [cls objectEnumerator];
    NSArray* curColor = nil;
    NSArray* MaxColor = nil;
    NSUInteger MaxCount = 0;
    while ((curColor = [enumertator nextObject]) != nil) {
        NSUInteger tmpCount = [cls countForObject:curColor];
        if (tmpCount < MaxCount) continue;
        MaxCount = tmpCount;
        MaxColor = curColor;
    }
    return  [UIColor colorWithRed:[MaxColor[0]intValue]/255.0f green:[MaxColor[1]intValue]/255.0f blue:[MaxColor[2]intValue]/255.0f alpha:[MaxColor[3]intValue]/255.0f];
}

+ (UIImage *)cropImage:(UIImage *)sourceImage scaleRect: (CGRect)rect partRect:(CGRect)rect2 {
    
    CGSize size = rect.size;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(scaledImage == nil) {
        return nil;
    }
    CGImageRef imageRef = scaledImage.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, rect2);
    UIImage* cropImg = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return cropImg;
}

@end
