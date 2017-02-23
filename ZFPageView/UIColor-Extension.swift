
//
//  UIColor-Extension.swift
//  ZFPageView
//
//  Created by zhangzhifu on 2017/2/22.
//  Copyright © 2017年 seemygo. All rights reserved.
//

import UIKit


extension UIColor {
    // class修饰的函数就相当于OC中的类方法
    class func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256)) / 255.0, green: CGFloat(arc4random_uniform(256)) / 255.0, blue: CGFloat(arc4random_uniform(256)) / 255.0, alpha: 1.0)
    }
    
    // 默认参数
    // 特性: 在extension里面扩展构造函数,必须扩展便利构造函数
    /*
     1> 必须在init前添加convenience
     2> 必须调用self.init()原有的某一个构造函数
     3> 构造函数不需要返回值
     */
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    // 根据十六进制颜色表示法创建颜色对象
    convenience init?(hexString : String) {
        // 十六进制: ## # 0x 0X
        // 1. 判断字符串长度是否大于等于6
        guard hexString.characters.count >= 6 else { // 判断条件是否满足,不满足进入小括号,满足跳过
            return nil
        }
        
        // 2. 将字符串转成大写
        var hexTempString = hexString.uppercased()
        
        // 3. 判断字符串是否是0X开头/##FF0022
        if hexTempString.hasPrefix("0X") || hexTempString.hasPrefix("##") {
            hexTempString = (hexTempString as NSString).substring(from: 2)
        }
        
        // 4. 判断字符串是否是以#开头
        if hexTempString.hasPrefix("#") {
            hexTempString = (hexTempString as NSString).substring(from: 1)
        }
        
        // 5. 获取RGB分别对应的十六进制 "FF0022"
        var range = NSRange(location: 0, length: 2)
        let rHex = (hexTempString as NSString).substring(with: range)
        
        range.location = 2
        let gHex = (hexTempString as NSString).substring(with: range)
        
        range.location = 4
        let bHex = (hexTempString as NSString).substring(with: range)
        
        // 6. 将十六进制转成十进制
        var r : UInt32 = 0
        var g : UInt32 = 0
        var b : UInt32 = 0
        
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        
        self.init(r: CGFloat(r), g: CGFloat(g), b: CGFloat(b))
    }
}


// MARK:- 从颜色中获取RGB值
extension UIColor {
    func getRGBValue() -> (CGFloat, CGFloat, CGFloat) {
//        guard let cmps = cgColor.components else {
//            // break/continue/return/throw
//            fatalError("错误:请确定该颜色是通过RGB创建的")
//        }
//        return (cmps[0] * 255, cmps[1] * 255, cmps[2] * 255)
        
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        return (red * 255, green * 255, blue * 255)
    }
}
