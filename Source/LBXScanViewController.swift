//
//  LBXScanViewController.swift
//  swiftScan
//
//  Created by lbxia on 15/12/8.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol LBXScanViewControllerDelegate {
     func scanFinished(scanResult: LBXScanResult, error: String?)
}


open class LBXScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
 //返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
   open var scanResultDelegate: LBXScanViewControllerDelegate?
    
   open var scanObj: LBXScanWrapper?
    
   open var scanStyle: LBXScanViewStyle? = LBXScanViewStyle()
    
   open var qRScanView: LBXScanView?
    
    //启动区域识别功能
   open var isOpenInterestRect = false
    
    //识别码的类型
    var arrayCodeType:[String]?
    
    //是否需要识别后的当前图像
    var isNeedCodeImage = false

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
              // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }
    
    open func setNeedCodeImage(needCodeImg:Bool)
    {
        isNeedCodeImage = needCodeImg;
    }
    //设置框内识别
    open func setOpenInterestRect(isOpen:Bool){
        isOpenInterestRect = isOpen
    }
 
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawScanView()
       
        perform(#selector(LBXScanViewController.startScan), with: nil, afterDelay: 0.3)
        
    }
    
    open func startScan()
    {
        if(!LBXPermissions .isGetCameraPermission())
        {
            showMsg(title: nil, message: NSLocalizedString("Please allow to access your album in \"Setting\"->\"Privacy\"->\"Photos\".", comment: "Photos access"))
            //Please allow to access your album in "Setting"->"Privacy"->"Photos".
            return
        }
        
        if (scanObj == nil)
        {
            var cropRect = CGRect.zero
            if isOpenInterestRect
            {
                cropRect = LBXScanView.getScanRectWithPreView(preView: self.view, style:scanStyle! )
            }
            
            //识别各种码，
            //let arrayCode = LBXScanWrapper.defaultMetaDataObjectTypes()
            
            //指定识别几种码
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode128Code]
            }
            
            scanObj = LBXScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
                
                if let strongSelf = self
                {
                    //停止扫描动画
                    strongSelf.qRScanView?.stopScanAnimation()
                    
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
             })
        }
        
        //结束相机等待提示
        qRScanView?.deviceStopReadying()
        
        //开始扫描动画
        qRScanView?.startScanAnimation()
        
        //相机运行
        scanObj?.start()
    }
    
    open func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = LBXScanView(frame: self.view.frame,vstyle:scanStyle! )
            self.view.addSubview(qRScanView!)
        }
        qRScanView?.deviceStartReadying(readyStr: NSLocalizedString("Loading...", comment: "Loading..."))
        
    }
   
    
    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */
    open func handleCodeResult(arrayResult:[LBXScanResult])
    {
        
        if let delegate = scanResultDelegate  {
            
            self.navigationController? .popViewController(animated: true)
            let result:LBXScanResult = arrayResult[0]
            
            delegate.scanFinished(scanResult: result, error: nil)

        }else{
            
            for result:LBXScanResult in arrayResult
            {
                print("%@",result.strScanned ?? "")
            }
            
            let result:LBXScanResult = arrayResult[0]
            
            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    open func openPhotoAlbum()
    {
        if(!LBXPermissions.isGetPhotoPermission())
        {
            showMsg(title: nil, message: NSLocalizedString("Please allow to access your device's camera in \"Setting\"->\"Privacy\"->\"Camera\".", comment: "Camera access"))
            //Please allow to access your device's camera in "Setting"->"Privacy"->"Camera".
            return
        }
        
        let picker = UIImagePickerController()
        
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        picker.delegate = self;
        
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = LBXScanWrapper.recognizeQRImage(image: image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }
      
        showMsg(title: nil, message: NSLocalizedString("Identify failed", comment: "Identify failed"))
    }
    
    func showMsg(title:String?,message:String?)
    {
        if LBXScanWrapper.isSysIos8Later()
        {
        
            //if #available(iOS 8.0, *)
            
            let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default) { (alertAction) in
                
//                if let strongSelf = self
//                {
//                    strongSelf.startScan()
//                }
            }
            
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    deinit
    {
//        print("LBXScanViewController deinit")
    }
    
}





