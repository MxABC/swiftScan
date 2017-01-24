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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.backgroundColor = UIColor.white
        
        drawCodeShowView()
        
        createQR1()
        
        createCode128()
    }
    
    //MARK: ------二维码、条形码显示位置
    func drawCodeShowView()
    {
        //二维码
        
        let rect = CGRect(x: (self.view.frame.width-self.view.frame.width*5/6)/2, y: 100, width: self.view.frame.width*5/6, height: self.view.frame.width*5/6)
        qrView.frame = rect
        self.view.addSubview(qrView)
        
        qrView.backgroundColor = UIColor.white
        qrView.layer.shadowOffset = CGSize(width: 0, height: 2);
        qrView.layer.shadowRadius = 2;
        qrView.layer.shadowColor = UIColor.black.cgColor
        qrView.layer.shadowOpacity = 0.5;
        
        qrImgView.bounds = CGRect(x: 0, y: 0, width: qrView.frame.width-12, height: qrView.frame.width-12)
        qrImgView.center = CGPoint(x: qrView.frame.width/2, y: qrView.frame.height/2);
        qrView .addSubview(qrImgView)
        
        
        
        //条形码
        tView.frame = CGRect(x: (self.view.frame.width-self.view.frame.width*5/6)/2,
                             y: rect.maxY+20,
                             width: self.view.frame.width*5/6,
                             height: self.view.frame.width*5/6*0.5)
        self.view .addSubview(tView)
        tView.layer.shadowOffset = CGSize(width: 0, height: 2);
        tView.layer.shadowRadius = 2;
        tView.layer.shadowColor = UIColor.black.cgColor
        tView.layer.shadowOpacity = 0.5;
        
        
        tImgView.bounds = CGRect(x: 0, y: 0, width: tView.frame.width-12, height: tView.frame.height-12);
        tImgView.center = CGPoint(x: tView.frame.width/2, y: tView.frame.height/2);
        tView .addSubview(tImgView)
        
    }
    
    func createQR1()
    {
       // qrView.hidden = false
       // tView.hidden = true
        
        let qrImg = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator",codeString:"lbxia20091227@foxmail.com", size: qrImgView.bounds.size, qrColor: UIColor.black, bkColor: UIColor.white)
        
        let logoImg = UIImage(named: "logo.JPG")
        qrImgView.image = LBXScanWrapper.addImageLogo(srcImg: qrImg!, logoImg: logoImg!, logoSize: CGSize(width: 30, height: 30))
    }
    
    func createCode128()
    {
        
        let qrImg = LBXScanWrapper.createCode128(codeString: "005103906002", size: qrImgView.bounds.size, qrColor: UIColor.black, bkColor: UIColor.white)
        
       
        tImgView.image = qrImg

    }

    deinit
    {
        print("MyCodeViewController deinit")
    }
   

}
