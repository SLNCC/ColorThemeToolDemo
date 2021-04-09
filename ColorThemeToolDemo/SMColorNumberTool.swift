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
    static func getAHexColorWithColor(color: UIColor) -> String? {
       
        guard let components = color.cgColor.components else {
            return nil
        }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components[3]

        let red = String(UInt32(r * 255),radix: 16)
        let green = String(UInt32(g * 255),radix: 16)
        let blue = String(UInt32(b * 255),radix: 16)
        let alpa = String(UInt32(a * 255),radix: 16)
        return alpa + red + green + blue
    }
    
    /// UIColor 转化成UInt32
    /// - Parameter color: color
    /// - Returns: UInt32
    static func getColorUInt32WithColor(color: UIColor) -> UInt32 {
        guard let hex = getAHexColorWithColor(color: color) else {
            return 0
        }
        return getColorUInt32WithHex(hex)
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
