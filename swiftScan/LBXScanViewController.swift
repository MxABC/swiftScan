//
//  LBXScanViewController.swift
//  swiftScan
//
//  Created by csc on 15/12/8.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


class LBXScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let session = AVCaptureSession()
    var layer: AVCaptureVideoPreviewLayer?
    
    var scanStyle:LBXScanViewStyle?
    
    var qRScanView:LBXScanView?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
              // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.whiteColor()
      
        //没有效果
        if (respondsToSelector("setEdgesForExtendedLayout"))
        {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
    }

 
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.setupCamera()
        self.session.startRunning()        
        
        
        qRScanView = LBXScanView(frame: self.view.frame,vstyle:scanStyle! )
        self.view.addSubview(qRScanView!)
        qRScanView!.startScanAnimation()

    }
    
    
    
    func setupCamera(){
        self.session.sessionPreset = AVCaptureSessionPresetHigh
       
        var input:AVCaptureDeviceInput?;
        do{
            input = try AVCaptureDeviceInput(device: device)
        }
        catch let error as NSError {
            print("AVCaptureDeviceInput(): \(error)")
        }
        
        
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        layer = AVCaptureVideoPreviewLayer(session: session)
        layer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer!.frame = CGRectMake(0.0,0.0,CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame));
        self.view.layer.insertSublayer(layer!, atIndex: 0)
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
        }
        
        session.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
        }
        session.stopRunning()
        print("code is \(stringValue)")
        
        //        let alertController = UIAlertController(title: "二维码", message: "扫到的二维码内容为:\(stringValue)", preferredStyle: UIAlertControllerStyle.Alert)
        //        alertController.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler: nil))
        //        self.presentViewController(alertController, animated: true, completion: nil)
        let alertView = UIAlertView()
        alertView.delegate=self
        alertView.title = "二维码"
        alertView.message = "扫到的二维码内容为:\(stringValue)"
        alertView.addButtonWithTitle("确认")
        alertView.show()
        
        performSelector( "restartRun", withObject: nil, afterDelay: 3.0);
    }

    func restartRun()
    {
        session.startRunning()
    }
    
    
}
