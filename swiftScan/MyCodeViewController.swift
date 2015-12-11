//
//  MyCodeViewController.swift
//  swiftScan
//
//  Created by xialibing on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit

class MyCodeViewController: UIViewController {

    //二维码
    var qrView = UIView()
    var qrImgView = UIImageView()
    
    //条形码
    var tView = UIView()
    var tImgView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        drawCodeShowView()
        
        createQR1()
        
        createCode128()
    }
    
    //MARK: ------二维码、条形码显示位置
    func drawCodeShowView()
    {
        //二维码
        
        let rect = CGRectMake( (CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.view.frame)*5/6)/2, 100, CGRectGetWidth(self.view.frame)*5/6, CGRectGetWidth(self.view.frame)*5/6)
        qrView.frame = rect
        self.view.addSubview(qrView)
        
        qrView.backgroundColor = UIColor.whiteColor()
        qrView.layer.shadowOffset = CGSizeMake(0, 2);
        qrView.layer.shadowRadius = 2;
        qrView.layer.shadowColor = UIColor.blackColor().CGColor
        qrView.layer.shadowOpacity = 0.5;
        
        qrImgView.bounds = CGRectMake(0, 0, CGRectGetWidth(qrView.frame)-12, CGRectGetWidth(qrView.frame)-12)
        qrImgView.center = CGPointMake(CGRectGetWidth(qrView.frame)/2, CGRectGetHeight(qrView.frame)/2);
        qrView .addSubview(qrImgView)
        
        
        
        //条形码
        tView.frame = CGRectMake( (CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.view.frame)*5/6)/2,
            CGRectGetMaxY(rect)+20,
            CGRectGetWidth(self.view.frame)*5/6,
            CGRectGetWidth(self.view.frame)*5/6*0.5)
        self.view .addSubview(tView)
        tView.layer.shadowOffset = CGSizeMake(0, 2);
        tView.layer.shadowRadius = 2;
        tView.layer.shadowColor = UIColor.blackColor().CGColor
        tView.layer.shadowOpacity = 0.5;
        
        
        tImgView.bounds = CGRectMake(0, 0, CGRectGetWidth(tView.frame)-12, CGRectGetHeight(tView.frame)-12);
        tImgView.center = CGPointMake(CGRectGetWidth(tView.frame)/2, CGRectGetHeight(tView.frame)/2);
        tView .addSubview(tImgView)
        
    }
    
    func createQR1()
    {
       // qrView.hidden = false
       // tView.hidden = true
        
        let qrImg = LBXScanWrapper.createCode("CIQRCodeGenerator",codeString:"lbxia20091227@foxmail.com", size: qrImgView.bounds.size, qrColor: UIColor.blackColor(), bkColor: UIColor.whiteColor())
        
        let logoImg = UIImage(named: "logo.JPG")
        qrImgView.image = LBXScanWrapper.addImageLogo(qrImg!, logoImg: logoImg!, logoSize: CGSizeMake(30, 30))
    }
    
    func createCode128()
    {
        
        let qrImg = LBXScanWrapper.createCode128("005103906002", size: qrImgView.bounds.size, qrColor: UIColor.blackColor(), bkColor: UIColor.whiteColor())
        
       
        tImgView.image = qrImg

    }

    deinit
    {
        print("MyCodeViewController deinit")
    }
   

}
