//
//  SMColorThemeTool.swift
//  Keyboard
//
//  Created by a on 2021/4/7.
//  Copyright © 2021 Joedd. All rights reserved.
//

/**
 //  Thanks  🙏🙏🙏🙏
 //  ------
 //  Lokesh Dhakar - for the original Color Thief JavaScript version
 //  http://lokeshdhakar.com/projects/color-thief/
 //  Sven Woltmann - for the fast Java Implementation
 //  https://github.com/SvenWoltmann/color-thief-java
 // Kazuki Ohara  --- for the fast Swift Implementation
 // https://github.com/yamoridon/ColorThiefSwift
 // AIHGF ---  for the fast Python Implementation
 // https://www.aiuai.cn/aifarm1158.html
 */
import UIKit

class SMColorThemeTool {
    
    /// 取view的某个区域的主调色
    /// - Parameters:
    ///   - view: view
    ///   - rect: 裁剪区域（在rect中裁剪）区域近可能的小
    /// - Returns:
    static func mostColor(source view: UIView, part rect: CGRect) -> UIColor? {
        return mostColor(source: generateImage(source: view, part: rect))
    }
    
    /// 取view的某个区域的主调色--使用ColorThief的框架的算法
    /// - Parameters:
    ///   - view: view
    ///   - rect: 裁剪区域（在rect中裁剪）区域近可能的小
    ///   - quality: 1~10
    ///   - ignoreWhite: true
    /// - Returns:
    static func mostColorByColorThief(source view: UIView, part rect: CGRect, quality: Int = 5, ignoreWhite: Bool = true) -> UIColor? {
        return mostColorByColorThief(source: generateImage(source: view, part: rect), quality: quality, ignoreWhite: ignoreWhite)
    }

    /// 取图片的主调色
    /// - Parameters:
    ///   - image: 图片
    ///   - rect: 适配图片，一般指当前展示在屏幕上的图片区域
    ///   - rect2: 裁剪区域（在rect中裁剪）区域近可能的小
    static func mostColor(source image: UIImage, scale rect: CGRect, part rect2: CGRect) -> UIColor? {
        guard let cropImage = self.cropImage(source: image, scale: rect, part: rect2) else {
            return nil
        }
        return mostColor(source: cropImage)
    }
    
    /// 取图片的主调色
    /// - Parameter image: image
    /// - Returns: UIColor?
    static func mostColor(source image: UIImage) -> UIColor? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height:  image.size.height))
        let cls = NSCountedSet(capacity: width * height)
        for x in 0..<width {
            for y in 0..<height {
                let offset = 4 * x * y
                let r = rawData[offset]
                let g = rawData[offset + 1]
                let b = rawData[offset + 2]
                let a = rawData[offset + 3]
                if (a > 0) {//去除透明
                    if (r == 255 && g == 255 && b == 255) {//去除白色
                    }else{
                        let arr = [CGFloat(r),CGFloat(g),CGFloat(b),CGFloat(a)]
                        cls.add(arr)
                    }
                }
            }
        }
        let enumertator = cls.objectEnumerator()
        var maxColor: Array<CGFloat>? = nil
        var maxCount = 0
        while let curColor = enumertator.nextObject() {
            let tmpCount = cls.count(for: curColor)
            if tmpCount >= maxCount {
                maxCount = tmpCount
                maxColor = curColor as? Array<CGFloat>
            }
        }
        
        guard let maxColor1 = maxColor else {
            return nil
        }
        let color = UIColor(red: maxColor1[0]/255, green: maxColor1[1]/255, blue: maxColor1[2]/255, alpha: maxColor1[3]/255)
        return color
    }
    
    /// 取图片的主调色--使用ColorThief的框架的算法
    /// - Parameter image: image
    /// - Returns: UIColor?
    static func mostColorByColorThief(source image: UIImage, quality: Int = 5, ignoreWhite: Bool = true) -> UIColor? {
        return ColorThief.getColor(from: image, quality: quality, ignoreWhite: ignoreWhite)?.makeUIColor()
    }
    
    /// 裁剪部分视图
    /// - Parameters:
    ///   - view: view
    ///   - rect: 裁剪区域（在view中裁剪）
    static func generateImage(source view: UIView, part rect: CGRect) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.prefersExtendedRange = true
        let renderer = UIGraphicsImageRenderer(bounds: rect, format: format)
        let cropImage = renderer.image { (context)  in
            context.cgContext.concatenate(CGAffineTransform.identity.scaledBy(x: 1, y: 1))
            return view.layer.render(in: context.cgContext)
        }
        return cropImage
    }
    
    /// 裁剪图片
    /// - Parameters:
    ///   - image: 图片
    ///   - rect: 适配图片
    ///   - rect2: 裁剪区域（在rect中裁剪）
    static func cropImage(source image: UIImage, scale rect: CGRect, part rect2: CGRect) -> UIImage? {
        
        let size = rect.size
        let imageSize = image.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = size.width
        let targetHeight = size.height
        var scaleFactor: CGFloat = 0.0
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint = CGPoint(x: 0, y: 0)
        
        if(imageSize.equalTo(size) == false) {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            if(widthFactor > heightFactor) {
                scaleFactor = widthFactor
            }else{
                scaleFactor = heightFactor
            }
            scaledWidth = width * scaleFactor
            scaledHeight = height * scaleFactor
            if(widthFactor > heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            }else if(widthFactor < heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
            }
        }

        UIGraphicsBeginImageContext(size)
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaledWidth
        thumbnailRect.size.height = scaledHeight
        image.draw(in: thumbnailRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let imageRef = scaledImage?.cgImage else { return nil }
        guard let imagePartRef = imageRef.cropping(to: rect2) else {return nil}
        let cropImg = UIImage(cgImage: imagePartRef)
        return cropImg;
    }

}
