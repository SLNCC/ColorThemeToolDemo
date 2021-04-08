//
//  SMColorThemeTool.swift
//  Keyboard
//
//  Created by a on 2021/4/7.
//  Copyright © 2021 Joedd. All rights reserved.
//

import UIKit

class SMColorThemeTool {
    
    
    /// 取图片的主调色
    /// - Parameters:
    ///   - image: 图片
    ///   - rect: 适配图片，一般指当前展示在屏幕上的图片区域
    ///   - rect2: 裁剪区域（在rect中裁剪）区域近可能的小
    static func mostColor(source image: UIImage, scale rect: CGRect, part rect2: CGRect) -> UIColor? {
        guard let cropImage = self.cropImage(source: image, scale: rect, part: rect2), let cropCgImage = cropImage.cgImage else {
            return nil
        }
        
        let cropWidth = Int(cropImage.size.width)
        let cropHeight = Int(cropImage.size.height)
        var rawData = [UInt8](repeating: 0, count: cropWidth * cropHeight * 4)
        guard let context = CGContext(data: &rawData,
                                      width: cropWidth,
                                      height: cropHeight,
                                      bitsPerComponent: 8,
                                      bytesPerRow: cropWidth * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cropCgImage, in: CGRect(x: 0, y: 0, width: cropImage.size.width, height:  cropImage.size.height))
        let cls = NSCountedSet(capacity: cropWidth * cropHeight)
        for x in 0..<cropWidth {
            for y in 0..<cropHeight {
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
    
    /// 16进制颜色转为 UInt32
    /// - Parameters:
    ///   - hex: 16进制  HEX：6    AHEX： 8
    ///   - alpha: alpha 范围  0~1
    /// - Returns: UInt32
    static func getColorUInt32WithSixHex(_ hex: String, alpha: CGFloat? =  nil) -> UInt32 {
        var result = hex
        if let alpa = alpha, alpa >= 0 && alpa <= 1 {
            let alpaHex = String(UInt32(alpa * 255),radix: 16)
            if result.hasPrefix("#") {
                let index = result.index(result.startIndex, offsetBy: 1)
                result.insert(contentsOf: alpaHex, at: index)
            }else {
                result = alpaHex + result
            }
            result = result.uppercased()
        }
        return getColorUInt32WithHex(result)
    }
    
    /// 16进制颜色转为 UInt32
    /// - Parameter hex: 16进制
    /// - Returns: UInt32
    static func getColorUInt32WithHex(_ hex: String) -> UInt32 {
        let colorHex = pregReplace(content: hex, pattern: "#", replaceString: "0x")
        let scanner = Scanner(string: colorHex)
        var hexNum: UInt32 = 0
        scanner.scanHexInt32(&hexNum)
        return hexNum
    }
    
    /// 颜色 10进制转化成UIColor
    /// - Parameters:
    ///   - value: UInt32  （ AHEX、HEX）
    ///   - alpha: 设置透明度 范围：0～1
    /// - Returns: UIColor
    static func getColorWithUInt32(_ value: UInt32, alpha: CGFloat? = nil) -> UIColor {
        return getColorWithHex(String(value, radix: 16),alpha: alpha)
    }
    
    /// 16进制转化成color
    /// - Parameters:
    ///   - hex: 16进制  6、7位 对应HEX、8位对应AHEX
    ///   - alpha: 0～1
    static func getColorWithHex(_ hex: String, alpha: CGFloat? = nil) -> UIColor {
        var hexString = hex.uppercased()
        if (hexString.hasPrefix("##") || hexString.hasPrefix("0x") || hexString.hasPrefix("0X")) {
            hexString = (hexString as NSString).substring(from: 2)
        }
        if (hexString.hasPrefix("#")) {
            hexString = (hexString as NSString).substring(from: 1)
        }
        
        guard hexString.count >= 6 else {
            return UIColor.clear
        }
        if hexString.count > 8 {
            hexString = String(hexString.prefix(8))
        }
        var a: UInt32 = 255
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        
        if hexString.count == 6 || hexString.count == 7 {//HEX
            var range = NSRange(location: 0, length: 2)
            let rStr = (hexString as NSString).substring(with: range)
            
            range.location = 2
            let gStr = (hexString as NSString).substring(with: range)
            
            range.location = 4
            let bStr = (hexString as NSString).substring(with: range)
    
            Scanner(string: rStr).scanHexInt32(&r)
            Scanner(string: gStr).scanHexInt32(&g)
            Scanner(string: bStr).scanHexInt32(&b)
        }else if hexString.count == 8 {//AHEX
            var range = NSRange(location: 0, length: 2)
            let aStr = (hexString as NSString).substring(with: range)
            
            range.location = 2
            let rStr = (hexString as NSString).substring(with: range)
            
            range.location = 4
            let gStr = (hexString as NSString).substring(with: range)
            
            range.location = 6
            let bStr = (hexString as NSString).substring(with: range)

            Scanner(string: aStr).scanHexInt32(&a)
            Scanner(string: rStr).scanHexInt32(&r)
            Scanner(string: gStr).scanHexInt32(&g)
            Scanner(string: bStr).scanHexInt32(&b)
        }
        if let alpha = alpha {
            a = UInt32(alpha * 255)
        }
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255.0)
            
    }
    
    static func pregReplace(content: String, pattern: String, replaceString: String, options: NSRegularExpression.Options = []) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return regex.stringByReplacingMatches(in: content, options: [], range: NSMakeRange(0, content.count), withTemplate: replaceString)
        } catch {
            
        }
        return replaceString
    }

}
