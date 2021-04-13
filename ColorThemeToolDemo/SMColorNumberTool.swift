//
//  SMColorNumberTool.swift
//  ColorThemeToolDemo
//
//  Created by a on 2021/4/9.
//

import UIKit

class SMColorNumberTool {
    
    
    /// UIColor 转化成Hex
    /// - Parameter color: UIColor
    /// - Returns: AHEX
    static func getAHexColor(color: UIColor) -> String? {
       
        guard let components = color.cgColor.components else {
            return nil
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        var a: CGFloat = 1.0
        if components.count >= 3 {
            a = components[3]
        }
        return String(format: "%02X%02X%02X%02X",UInt32(a * 255), UInt32(r * 255),UInt32(g * 255),UInt32(b * 255))
    }
    
    /// UIColor 转化成UInt32
    /// - Parameter color: color
    /// - Returns: UInt32
    static func getColorUInt32ByColor(color: UIColor) -> UInt32 {
        guard let hex = getAHexColor(color: color) else {
            return 0
        }
        return getColorUInt32ByHex(hex)
    }
    
    /// 颜色 10进制转化成10进制
    /// - Parameters:
    ///   - value: UInt32  HEX: 6
    ///   - alpha: 设置透明度 范围：0～1
    /// - Returns: UIColor
    static func getColorUInt32ByUInt32(_ value: UInt32, alpha: CGFloat? = nil) -> UInt32 {
        return getColorUInt32ByHex(String(value, radix: 16), alpha: alpha)
    }
    
    /// 16进制颜色转为 UInt32
    /// - Parameters:
    ///   - hex: 16进制  HEX：6    AHEX： 8
    ///   - alpha: alpha 范围  0~1
    /// - Returns: UInt32
    static func getColorUInt32ByHex(_ hex: String, alpha: CGFloat? =  nil) -> UInt32 {
        if alpha == 0 {
            return 0
        }
        var result = hex
        if (result.hasPrefix("##") || result.hasPrefix("0x")) {
            result =  String(result.suffix(from: result.index(result.startIndex, offsetBy: 2)))
        }
        if (result.hasPrefix("#")) {
            result = String(result.suffix(from: result.index(result.startIndex, offsetBy: 1)))
        }
        if result.count > 8 {
            result = String(result.prefix(8))
        }
        if result.count < 6 {//补全6位
            let count = 6 - result.count
            let arr = Array(0..<count).map { (_) -> Character in
                return "0"
            }
            let index = result.index(result.startIndex, offsetBy: 0)
            result.insert(contentsOf: arr, at: index)
        }
        if let alpa = alpha, alpa > 0 && alpa <= 1 {
            if result.count == 6 {
                let alpaHex = String(format: "%02X",UInt32(alpa * 255))
                if result.hasPrefix("#") {
                    let index = result.index(result.startIndex, offsetBy: 1)
                    result.insert(contentsOf: alpaHex, at: index)
                }else {
                    result = alpaHex + result
                }
            }else if result.count == 8 {
                //透明度计算
                let preAlpha = String(result.prefix(2))
                let a = alpa * CGFloat(getColorUInt32ByHex(preAlpha))/CGFloat(255)
                let hexA = String(format: "%02X",UInt32(a * 255))
                if let r = result.range(of: preAlpha,options: .regularExpression) {
                    result.replaceSubrange(r, with: hexA)
                }
            }
            result = result.uppercased()
        }
        return getColorUInt32ByHex(result)
    }
    
    /// 16进制颜色转为 UInt32
    /// - Parameter hex: 16进制
    /// - Returns: UInt32
    static func getColorUInt32ByHex(_ hex: String) -> UInt32 {
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
    static func getColorUInt32(_ value: UInt32, alpha: CGFloat? = nil) -> UIColor {
        return getColorByHex(String(value, radix: 16),alpha: alpha)
    }
    
    /// 16进制转化成color
    /// - Parameters:
    ///   - hex: 16进制  hex 最大8位
    ///   - alpha: 0～1
    static func getColorByHex(_ hex: String, alpha: CGFloat? = nil) -> UIColor {
        var hexString = hex.uppercased()
        if (hexString.hasPrefix("##") || hexString.hasPrefix("0x") || hexString.hasPrefix("0X")) {
            hexString = (hexString as NSString).substring(from: 2)
        }
        if (hexString.hasPrefix("#")) {
            hexString = (hexString as NSString).substring(from: 1)
        }
        
        if hexString.count > 8 {
            hexString = String(hexString.prefix(8))
        }
        
        if hexString.count < 6 {//补全6位
            let count = 6 - hexString.count
            let arr = Array(0..<count).map { (_) -> Character in
                return "0"
            }
            let index = hexString.index(hexString.startIndex, offsetBy: 0)
            hexString.insert(contentsOf: arr, at: index)
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
