//
//  LBXScanWrapper.swift
//  swiftScan
//
//  Created by csc on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation

struct  LBXScanResult {
    
    //码内容
    var strScanned:String? = ""
    //扫描图像
    var imgScanned:UIImage?
    //码的类型
    var strBarCodeType:String? = ""
    
    init(str:String,img:UIImage?,barCodeType:String)
    {
        self.strScanned = str
        
        if img != nil
        {
            self.imgScanned = img
        }
       
        self.strBarCodeType = barCodeType
    }
}



class LBXScanWrapper: NSObject,AVCaptureMetadataOutputObjectsDelegate {
    
    let device:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
    
    var input:AVCaptureDeviceInput?
    var output:AVCaptureMetadataOutput
    
    let session = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var stillImageOutput:AVCaptureStillImageOutput?
    
    //存储返回结果
    var arrayResult:[LBXScanResult] = [];
    
    //扫码结果返回block
    var successBlock:([LBXScanResult]) -> Void
    
    //是否需要拍照
    var isNeedCaptureImage:Bool
    
    //当前扫码结果是否处理
    var isNeedScanResult:Bool = true
    
    /**
     初始化设备
     - parameter videoPreView: 视频显示UIView
     - parameter objType:      识别码的类型,缺省值 QR二维码
     - parameter isCaptureImg: 识别后是否采集当前照片
     - parameter cropRect:     识别区域
     - parameter success:      返回识别信息
     - returns:
     */
    init( videoPreView:UIView,objType:[String] = [AVMetadataObjectTypeQRCode],isCaptureImg:Bool,cropRect:CGRect=CGRectZero,success:( ([LBXScanResult]) -> Void) )
    {
        do{
            input = try AVCaptureDeviceInput(device: device)
        }
        catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
            
            
        }
        
        // Output
        output = AVCaptureMetadataOutput()
        
        stillImageOutput = AVCaptureStillImageOutput();
        
        isNeedCaptureImage = isCaptureImg
        
        successBlock = success
        
        super.init()
        
        if session.canAddInput(input)
        {
            session.addInput(input)
        }
        if session.canAddOutput(output)
        {
            session.addOutput(output)
        }
        if session.canAddOutput(stillImageOutput)
        {
            session.addOutput(stillImageOutput)
        }
        
        let outputSettings:Dictionary = [AVVideoCodecJPEG:AVVideoCodecKey]
        stillImageOutput?.outputSettings = outputSettings
        
        
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        //参数设置
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        
        output.metadataObjectTypes = objType
        
        //output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        if !CGRectEqualToRect(cropRect, CGRectZero)
        {
            //启动相机后，直接修改该参数无效
            output.rectOfInterest = cropRect
        }

        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        var frame:CGRect = videoPreView.frame
        frame.origin = CGPointZero
        previewLayer?.frame = frame
        
        videoPreView.layer .insertSublayer(previewLayer!, atIndex: 0)
        
        
        if ( device.focusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus) )
        {
            do
            {
                try input?.device.lockForConfiguration()
                
                input?.device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                
                input?.device.unlockForConfiguration()
            }
            catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
                
            }
        }
        
    }
    
    func start()
    {
        if !session.running
        {
            isNeedScanResult = true
            session.startRunning()
        }
    }
    func stop()
    {
        if session.running
        {
            isNeedScanResult = false
            session.stopRunning()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        if !isNeedScanResult
        {
            //上一帧处理中
            return
        }
        
        isNeedScanResult = false
        
        arrayResult.removeAll()
        
        //识别扫码类型
        for current:AnyObject in metadataObjects
        {
            if current.isKindOfClass(AVMetadataMachineReadableCodeObject)
            {
                //码类型
                let codeType = (current as! AVMetadataObject).type
                print("code type:%@",codeType)
                //码内容
                let codeContent = (current as! AVMetadataMachineReadableCodeObject).stringValue
                print("code string:%@",codeContent)
                
                arrayResult.append(LBXScanResult(str: codeContent, img: UIImage(), barCodeType: codeType))
            }
        }
        
        if arrayResult.count > 0
        {
            if isNeedCaptureImage
            {
                captureImage()
            }
            else
            {
                stop()
                successBlock(arrayResult)
            }
            
        }
        else
        {
            isNeedScanResult = true
        }
        
    }
    
    
    //MARK: ----拍照
    func captureImage()
    {
        let stillImageConnection:AVCaptureConnection? = connectionWithMediaType(AVMediaTypeVideo, connections: (stillImageOutput?.connections)!)
        
        
        stillImageOutput?.captureStillImageAsynchronouslyFromConnection(stillImageConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
            
            self.stop()
            if imageDataSampleBuffer != nil
            {
                let imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                let scanImg:UIImage? = UIImage(data: imageData)
                
                
                for idx in 0...self.arrayResult.count
                {
                    self.arrayResult[idx].imgScanned = scanImg
                }
            }
            
            self.successBlock(self.arrayResult)
            
        })
    }
    
    func connectionWithMediaType(mediaType:String,connections:[AnyObject]) -> AVCaptureConnection?
    {
        for connection:AnyObject in connections
        {
            let connectionTmp:AVCaptureConnection = connection as! AVCaptureConnection
            for port:AnyObject in connectionTmp.inputPorts
            {
                if port.isKindOfClass(AVCaptureInputPort)
                {
                    let portTmp:AVCaptureInputPort = port as! AVCaptureInputPort
                    if portTmp.mediaType == mediaType
                    {
                        return connectionTmp
                    }
                }
            }
        }
        return nil
    }
    
    
    //MARK:切换识别区域
    func changeScanRect(cropRect:CGRect)
    {
        //待测试，不知道是否有效
        stop()
        output.rectOfInterest = cropRect
        start()
    }

    //MARK: 切换识别码的类型
    func changeScanType(objType:[String])
    {
        //待测试中途修改是否有效
        output.metadataObjectTypes = objType
    }

    /**
     打开或关闭闪关灯
     - parameter torch: true：打开闪关灯 false:关闭闪光灯
     */
    func setTorch(torch:Bool)
    {
        do
        {
            try input?.device.lockForConfiguration()
            
            input?.device.torchMode = torch ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off            
            
            input?.device.unlockForConfiguration()
        }
        catch let error as NSError {
            print("device.lockForConfiguration(): \(error)")
            
        }
    }
    
    
    /**
    ------闪光灯打开或关闭
    */
    func changeTorch()
    {
        do
        {
            try input?.device.lockForConfiguration()
            
            var torch = false
            
            if input?.device.torchMode == AVCaptureTorchMode.On
            {
                torch = false
            }
            else if input?.device.torchMode == AVCaptureTorchMode.Off
            {
                torch = true
            }
            
            input?.device.torchMode = torch ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
            
            input?.device.unlockForConfiguration()
        }
        catch let error as NSError {
            print("device.lockForConfiguration(): \(error)")
            
        }
    }
    
    //MARK: ------获取系统默认支持的码的类型
    static func defaultMetaDataObjectTypes() ->[String]
    {
        var types =
           [AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeAztecCode,
            AVMetadataObjectTypeInterleaved2of5Code,
            AVMetadataObjectTypeITF14Code,
            AVMetadataObjectTypeDataMatrixCode
        ];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_0)
        {
            types.append(AVMetadataObjectTypeInterleaved2of5Code)
            types.append(AVMetadataObjectTypeITF14Code)
            types.append(AVMetadataObjectTypeDataMatrixCode)
            
        }
        
        return types;
    }



}
