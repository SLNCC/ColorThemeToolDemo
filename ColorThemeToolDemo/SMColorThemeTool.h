//
//  SMColorThemeTool.h
//  Keyboard
//
//  Created by a on 2021/4/6.
//  Copyright © 2021 Joedd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SMColorThemeTool : NSObject
/// 获取图片的主色调
/// @param sourceImage 图片
/// @param rect 适配图片
/// @param rect2 裁剪的范围
+ (UIColor *)mostColor:(UIImage *)sourceImage scaleRect:(CGRect)rect partRect:(CGRect)rect2;

/// 裁剪
/// @param sourceImage 图
/// @param rect 适配图片
/// @param rect2 裁剪的范围
+ (UIImage *)cropImage:(UIImage *)sourceImage scaleRect:(CGRect)rect partRect:(CGRect)rect2;
@end

NS_ASSUME_NONNULL_END
