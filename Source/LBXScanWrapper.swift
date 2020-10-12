//
//  LBXScanWrapper.swift
//  swiftScan
//
//  Created by lbxia on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation

public struct LBXScanResult {
    
    /// 码内容
    public var strScanned: String?
    
    /// 扫描图像
    public var imgScanned: UIImage?
    
    /// 码的类型
    public var strBarCodeType: String?

    /// 码在图像中的位置
    public var arrayCorner: [AnyObject]?

    public init(str: String?, img: UIImage?, barCodeType: String?, corner: [AnyObject]?) {
        strScanned = str
        imgScanned = img
        strBarCodeType = barCodeType
        arrayCorner = corner
    }
}



open class LBXScanWrapper: NSObject,AVCaptureMetadataOutputObjectsDelegate {
    
    let device = AVCaptureDevice.default(for: AVMediaType.video)
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput

    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput

    // 存储返回结果
    var arrayResult = [LBXScanResult]()

    // 扫码结果返回block
    var successBlock: ([LBXScanResult]) -> Void

    // 是否需要拍照
    var isNeedCaptureImage: Bool

    // 当前扫码结果是否处理
    var isNeedScanResult = true
    
    //连续扫码
    var supportContinuous = false
    
    
    /**
     初始化设备
     - parameter videoPreView: 视频显示UIView
     - parameter objType:      识别码的类型,缺省值 QR二维码
     - parameter isCaptureImg: 识别后是否采集当前照片
     - parameter cropRect:     识别区域
     - parameter success:      返回识别信息
     - returns:
     */
    init(videoPreView: UIView,
         objType: [AVMetadataObject.ObjectType] = [(AVMetadataObject.ObjectType.qr as NSString) as AVMetadataObject.ObjectType],
         isCaptureImg: Bool,
         cropRect: CGRect = .zero,
         success: @escaping (([LBXScanResult]) -> Void)) {
        
        successBlock = success
        output = AVCaptureMetadataOutput()
        isNeedCaptureImage = isCaptureImg
        stillImageOutput = AVCaptureStillImageOutput()

        super.init()
        
        guard let device = device else {
            return
        }
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        guard let input = input else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }

        stillImageOutput.outputSettings = [AVVideoCodecJPEG: AVVideoCodecKey]

        session.sessionPreset = AVCaptureSession.Preset.high

        // 参数设置
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

        output.metadataObjectTypes = objType

        //        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]

        if !cropRect.equalTo(CGRect.zero) {
            // 启动相机后，直接修改该参数无效
            output.rectOfInterest = cropRect
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

        var frame: CGRect = videoPreView.frame
        frame.origin = CGPoint.zero
        previewLayer?.frame = frame

        videoPreView.layer.insertSublayer(previewLayer!, at: 0)

        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            do {
                try input.device.lockForConfiguration()
                input.device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                input.device.unlockForConfiguration()
            } catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
        }
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        captureOutput(output, didOutputMetadataObjects: metadataObjects, from: connection)
    }
    
    func start() {
        if !session.isRunning {
            isNeedScanResult = true
            session.startRunning()
        }
    }
    
    func stop() {
        if session.isRunning {
            isNeedScanResult = false
            session.stopRunning()
        }
    }
    
    open func captureOutput(_ captureOutput: AVCaptureOutput,
                            didOutputMetadataObjects metadataObjects: [Any],
                            from connection: AVCaptureConnection!) {
        guard isNeedScanResult else {
            // 上一帧处理中
            return
        }
        isNeedScanResult = false

        arrayResult.removeAll()

        // 识别扫码类型
        for current in metadataObjects {
            guard let code = current as? AVMetadataMachineReadableCodeObject else {
                continue
            }
            
            #if !targetEnvironment(simulator)
            
            arrayResult.append(LBXScanResult(str: code.stringValue,
                                             img: UIImage(),
                                             barCodeType: code.type.rawValue,
                                             corner: code.corners as [AnyObject]?))
            #endif
        }

        if arrayResult.isEmpty || supportContinuous {
            isNeedScanResult = true
        }
        if !arrayResult.isEmpty {
            
            if supportContinuous {
                successBlock(arrayResult)
            }
            else if isNeedCaptureImage {
                captureImage()
            } else {
                stop()
                successBlock(arrayResult)
            }
        }
    }
    
    //MARK: ----拍照
    open func captureImage() {
        guard let stillImageConnection = connectionWithMediaType(mediaType: AVMediaType.video as AVMediaType,
                                                                 connections: stillImageOutput.connections as [AnyObject]) else {
                                                                    return
        }
        stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection, completionHandler: { (imageDataSampleBuffer, _) -> Void in
            self.stop()
            if let imageDataSampleBuffer = imageDataSampleBuffer,
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                
                let scanImg = UIImage(data: imageData)
                for idx in 0 ... self.arrayResult.count - 1 {
                    self.arrayResult[idx].imgScanned = scanImg
                }
            }
            self.successBlock(self.arrayResult)
        })
    }
    
    open func connectionWithMediaType(mediaType: AVMediaType, connections: [AnyObject]) -> AVCaptureConnection? {
        for connection in connections {
            guard let connectionTmp = connection as? AVCaptureConnection else {
                continue
            }
            for port in connectionTmp.inputPorts where port.mediaType == mediaType {
                return connectionTmp
            }
        }
        return nil
    }
    
    
    //MARK: 切换识别区域

    open func changeScanRect(cropRect: CGRect) {
        // 待测试，不知道是否有效
        stop()
        output.rectOfInterest = cropRect
        start()
    }

    //MARK: 切换识别码的类型
    open func changeScanType(objType: [AVMetadataObject.ObjectType]) {
        // 待测试中途修改是否有效
        output.metadataObjectTypes = objType
    }
    
    open func isGetFlash() -> Bool {
        return device != nil && device!.hasFlash && device!.hasTorch
    }
    
    /**
     打开或关闭闪关灯
     - parameter torch: true：打开闪关灯 false:关闭闪光灯
     */
    open func setTorch(torch: Bool) {
        guard isGetFlash() else {
            return
        }
        do {
            try input?.device.lockForConfiguration()
            input?.device.torchMode = torch ? AVCaptureDevice.TorchMode.on : AVCaptureDevice.TorchMode.off
            input?.device.unlockForConfiguration()
        } catch let error as NSError {
            print("device.lockForConfiguration(): \(error)")
        }
    }
    
    
    /// 闪光灯打开或关闭
    open func changeTorch() {
        let torch = input?.device.torchMode == .off
        setTorch(torch: torch)
    }
    
    //MARK: ------获取系统默认支持的码的类型
    static func defaultMetaDataObjectTypes() -> [AVMetadataObject.ObjectType] {
        var types =
            [
                AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.upce,
                AVMetadataObject.ObjectType.code39,
                AVMetadataObject.ObjectType.code39Mod43,
                AVMetadataObject.ObjectType.ean13,
                AVMetadataObject.ObjectType.ean8,
                AVMetadataObject.ObjectType.code93,
                AVMetadataObject.ObjectType.code128,
                AVMetadataObject.ObjectType.pdf417,
                AVMetadataObject.ObjectType.aztec,
            ]
        // if #available(iOS 8.0, *)

        types.append(AVMetadataObject.ObjectType.interleaved2of5)
        types.append(AVMetadataObject.ObjectType.itf14)
        types.append(AVMetadataObject.ObjectType.dataMatrix)
        return types
    }
    
    /**
     识别二维码码图像
     
     - parameter image: 二维码图像
     
     - returns: 返回识别结果
     */
    public static func recognizeQRImage(image: UIImage) -> [LBXScanResult] {
        guard let cgImage = image.cgImage else {
            return []
        }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        let img = CIImage(cgImage: cgImage)
        let features = detector.features(in: img, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        return features.filter {
            $0.isKind(of: CIQRCodeFeature.self)
        }.map {
            $0 as! CIQRCodeFeature
        }.map {
            LBXScanResult(str: $0.messageString,
                          img: image,
                          barCodeType: AVMetadataObject.ObjectType.qr.rawValue,
                          corner: nil)
        }
    }
    
    
    //MARK: -- - 生成二维码，背景色及二维码颜色设置
    public static func createCode(codeType: String, codeString: String, size: CGSize, qrColor: UIColor, bkColor: UIColor) -> UIImage? {
        let stringData = codeString.data(using: .utf8)

        // 系统自带能生成的码
        //        CIAztecCodeGenerator
        //        CICode128BarcodeGenerator
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator
        let qrFilter = CIFilter(name: codeType)
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")

        // 上色
        let colorFilter = CIFilter(name: "CIFalseColor",
                                   parameters: [
                                       "inputImage": qrFilter!.outputImage!,
                                       "inputColor0": CIColor(cgColor: qrColor.cgColor),
                                       "inputColor1": CIColor(cgColor: bkColor.cgColor),
                                   ]
        )

        guard let qrImage = colorFilter?.outputImage,
        let cgImage = CIContext().createCGImage(qrImage, from: qrImage.extent) else {
            return nil
        }

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = CGInterpolationQuality.none
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return codeImage
    }
    
    public static func createCode128(codeString: String, size: CGSize, qrColor: UIColor, bkColor: UIColor) -> UIImage? {
        let stringData = codeString.data(using: String.Encoding.utf8)

        // 系统自带能生成的码
        //        CIAztecCodeGenerator 二维码
        //        CICode128BarcodeGenerator 条形码
        //        CIPDF417BarcodeGenerator
        //        CIQRCodeGenerator     二维码
        let qrFilter = CIFilter(name: "CICode128BarcodeGenerator")
        qrFilter?.setDefaults()
        qrFilter?.setValue(stringData, forKey: "inputMessage")

        guard let outputImage = qrFilter?.outputImage else {
            return nil
        }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1.0, orientation: UIImage.Orientation.up)

        // Resize without interpolating
        return resizeImage(image: image, quality: CGInterpolationQuality.none, rate: 20.0)
    }
    
    
    // 根据扫描结果，获取图像中得二维码区域图像（如果相机拍摄角度故意很倾斜，获取的图像效果很差）
    static func getConcreteCodeImage(srcCodeImage: UIImage, codeResult: LBXScanResult) -> UIImage? {
        let rect = getConcreteCodeRectFromImage(srcCodeImage: srcCodeImage, codeResult: codeResult)
        guard !rect.isEmpty, let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect) else {
            return nil
        }
        return imageRotation(image: img, orientation: UIImage.Orientation.right)
    }
    
    // 根据二维码的区域截取二维码区域图像
    public static func getConcreteCodeImage(srcCodeImage: UIImage, rect: CGRect) -> UIImage? {
        guard !rect.isEmpty, let img = imageByCroppingWithStyle(srcImg: srcCodeImage, rect: rect) else {
            return nil
        }
        return imageRotation(image: img, orientation: UIImage.Orientation.right)
    }
    
    // 获取二维码的图像区域
    public static func getConcreteCodeRectFromImage(srcCodeImage: UIImage, codeResult: LBXScanResult) -> CGRect {
        guard let corner = codeResult.arrayCorner as? [[String: Float]], corner.count >= 4 else {
            return .zero
        }

        let dicTopLeft = corner[0]
        let dicTopRight = corner[1]
        let dicBottomRight = corner[2]
        let dicBottomLeft = corner[3]

        let xLeftTopRatio = dicTopLeft["X"]!
        let yLeftTopRatio = dicTopLeft["Y"]!
        
        let xRightTopRatio = dicTopRight["X"]!
        let yRightTopRatio = dicTopRight["Y"]!

        let xBottomRightRatio = dicBottomRight["X"]!
        let yBottomRightRatio = dicBottomRight["Y"]!

        let xLeftBottomRatio = dicBottomLeft["X"]!
        let yLeftBottomRatio = dicBottomLeft["Y"]!

        // 由于截图只能矩形，所以截图不规则四边形的最大外围
        let xMinLeft = CGFloat(min(xLeftTopRatio, xLeftBottomRatio))
        let xMaxRight = CGFloat(max(xRightTopRatio, xBottomRightRatio))

        let yMinTop = CGFloat(min(yLeftTopRatio, yRightTopRatio))
        let yMaxBottom = CGFloat(max(yLeftBottomRatio, yBottomRightRatio))

        let imgW = srcCodeImage.size.width
        let imgH = srcCodeImage.size.height
        
        // 宽高反过来计算
        return CGRect(x: xMinLeft * imgH,
                      y: yMinTop * imgW,
                      width: (xMaxRight - xMinLeft) * imgH,
                      height: (yMaxBottom - yMinTop) * imgW)
    }
    
    //MARK: ----图像处理
    
    /**

    @brief  图像中间加logo图片
    @param srcImg    原图像
    @param LogoImage logo图像
    @param logoSize  logo图像尺寸
    @return 加Logo的图像
    */
    public static func addImageLogo(srcImg: UIImage, logoImg: UIImage, logoSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(srcImg.size)
        srcImg.draw(in: CGRect(x: 0, y: 0, width: srcImg.size.width, height: srcImg.size.height))
        let rect = CGRect(x: srcImg.size.width / 2 - logoSize.width / 2,
                          y: srcImg.size.height / 2 - logoSize.height / 2,
                          width: logoSize.width,
                          height: logoSize.height)
        logoImg.draw(in: rect)
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultingImage!
    }
    
    //图像缩放
    static func resizeImage(image: UIImage, quality: CGInterpolationQuality, rate: CGFloat) -> UIImage? {
        var resized: UIImage?
        let width = image.size.width * rate
        let height = image.size.height * rate

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))

        resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized
    }

    // 图像裁剪
    static func imageByCroppingWithStyle(srcImg: UIImage, rect: CGRect) -> UIImage? {
        guard let imagePartRef = srcImg.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imagePartRef)
    }
    
    // 图像旋转
    static func imageRotation(image: UIImage, orientation: UIImage.Orientation) -> UIImage {
        var rotate: Double = 0.0
        var rect: CGRect
        var translateX: CGFloat = 0.0
        var translateY: CGFloat = 0.0
        var scaleX: CGFloat = 1.0
        var scaleY: CGFloat = 1.0

        switch orientation {
        case .left:
            rotate = .pi / 2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = 0
            translateY = -rect.size.width
            scaleY = rect.size.width / rect.size.height
            scaleX = rect.size.height / rect.size.width
        case .right:
            rotate = 3 * .pi / 2
            rect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
            translateX = -rect.size.height
            translateY = 0
            scaleY = rect.size.width / rect.size.height
            scaleX = rect.size.height / rect.size.width
        case .down:
            rotate = .pi
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            translateX = -rect.size.width
            translateY = -rect.size.height
        default:
            rotate = 0.0
            rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            translateX = 0
            translateY = 0
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
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
}
