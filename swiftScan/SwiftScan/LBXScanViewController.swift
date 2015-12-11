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


class LBXScanViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var scanObj:LBXScanWrapper?
    
    var scanStyle:LBXScanViewStyle?
    
    var qRScanView:LBXScanView?
    
    //启动区域识别功能
    var isOpenInterestRect = false
    
    //识别码的类型
    var arrayCodeType:[String]?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
              // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.blackColor()
      
       
       // self.edgesForExtendedLayout = UIRectEdge.None
            
        
    }
 
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawScanView()
       
        performSelector("startScan", withObject: nil, afterDelay: 0.3)
        
    }
    
    func startScan()
    {
        if (scanObj == nil)
        {
            var cropRect = CGRectZero
            if isOpenInterestRect
            {
                cropRect = LBXScanView.getScanRectWithPreView(self.view, style:scanStyle! )
            }
            
            //识别各种码，
            //let arrayCode = LBXScanWrapper.defaultMetaDataObjectTypes()
            
            //指定识别几种码
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeCode128Code]
            }
            
            scanObj = LBXScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: false,cropRect:cropRect, success: { (arrayResult) -> Void in
                
                self.handleCodeResult(arrayResult)
            })
        }
        
        //结束相机等待提示
        qRScanView?.deviceStopReadying()
        
        //开始扫描动画
        qRScanView?.startScanAnimation()
        
        //相机运行
        scanObj?.start()
    }
    
    func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = LBXScanView(frame: self.view.frame,vstyle:scanStyle! )
            self.view.addSubview(qRScanView!)
        }
        
        qRScanView?.deviceStartReadying("相机启动中...")
        
    }
    
    func restartScan()
    {
        qRScanView?.startScanAnimation()
        self.scanObj?.start()
    }
    
    func handleCodeResult(arrayResult:[LBXScanResult])
    {
        //停止扫描动画
        qRScanView?.stopScanAnimation()
        
        scanResult(arrayResult)
    }
    
    
    /**
     需要对应处理的，如果是继承本控制器的，可以重写该方法
     */
    func scanResult(arrayResult:[LBXScanResult])
    {
        for result:LBXScanResult in arrayResult
        {
            print("%@",result.strScanned)
        }
        
        let result:LBXScanResult = arrayResult[0]
        
        showMsg(result.strBarCodeType, message: result.strScanned)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    func openPhotoAlbum()
    {
        let picker = UIImagePickerController()
        
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        picker.delegate = self;
        
        picker.allowsEditing = true
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = LBXScanWrapper.recognizeQRImage(image!)
            if arrayResult.count > 0
            {
                handleCodeResult(arrayResult)
                return
            }
        }
      
        showMsg("", message: "识别失败")
    }
    
    func showMsg(title:String?,message:String?)
    {
        if LBXScanWrapper.isSysIos8Later()
        {
            let alertController = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertAction = UIAlertAction(title:  "知道了", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                
                self.restartScan()
            }
            
            alertController.addAction(alertAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
}





