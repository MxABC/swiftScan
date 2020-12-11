//
// UIImage+swiftScan.swift
// swiftScan
//
// Create by wooseng with company's MackBook Pro on 2019/9/20.
// Copyright © 2019 xialibing. All rights reserved.
//


import UIKit

internal extension UIImage {
    
    // 图像裁剪
    func cropping(with rect: CGRect) -> UIImage? {
        guard let partRef = cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: partRef)
    }
    
    // 图像旋转，失败则返回原图
    func rotation(to orientation: Orientation) -> UIImage {
        var rotate: Double = 0.0
        var rect: CGRect
        var translateX: CGFloat = 0.0
        var translateY: CGFloat = 0.0
        var scaleX: CGFloat = 1.0
        var scaleY: CGFloat = 1.0

        switch orientation {
        case .left:
            rotate = .pi / 2
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            translateX = 0
            translateY = -rect.size.width
            scaleY = rect.size.width / rect.size.height
            scaleX = rect.size.height / rect.size.width
        case .right:
            rotate = 3 * .pi / 2
            rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
            translateX = -rect.size.height
            translateY = 0
            scaleY = rect.size.width / rect.size.height
            scaleX = rect.size.height / rect.size.width
        case .down:
            rotate = .pi
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            translateX = -rect.size.width
            translateY = -rect.size.height
        default:
            rotate = 0.0
            rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            translateX = 0
            translateY = 0
        }

        guard let cgImage = cgImage else {
            return self
        }
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        // 做CTM变换
        context.translateBy(x: 0.0, y: rect.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat(rotate))
        context.translateBy(x: translateX, y: translateY)
        context.scaleBy(x: scaleX, y: scaleY)
        // 绘制图片
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage ?? self
    }
    
    // 图像缩放，失败返回原图
    func resize(quality: CGInterpolationQuality, rate: CGFloat) -> UIImage {
        var resized: UIImage?
        let width = size.width * rate
        let height = size.height * rate
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized ?? self
    }
    
}

public extension UIImage {
    
    /// 图像中间增加logo
    ///
    /// - Parameters:
    ///   - logoImg: logo图片
    ///   - logoSize: logo图像尺寸
    /// - Returns: 添加logo之后的图片，如果添加失败，返回原图
    func addLogo(logoImg: UIImage, logoSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let rect = CGRect(x: size.width / 2 - logoSize.width / 2,
                          y: size.height / 2 - logoSize.height / 2,
                          width: logoSize.width,
                          height: logoSize.height)
        logoImg.draw(in: rect)
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
    }
    
}
