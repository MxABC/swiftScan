//
//  QQScanViewController.swift
//  swiftScan
//
//  Created by xialibing on 15/12/10.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit

class QQScanViewController: LBXScanViewController {
    
    
    /**
    @brief  扫码区域上方提示文字
    */
    var topTitle:UILabel?

    /**
     @brief  闪关灯开启状态
     */
    var isOpenedFlash:Bool = false
    
// MARK: - 底部几个功能：开启闪光灯、相册、我的二维码
    
    //底部显示的功能项
    var bottomItemsView:UIView?
    
    //相册
    var btnPhoto:UIButton = UIButton()
    
    //闪光灯
    var btnFlash:UIButton = UIButton()
    
    //我的二维码
    var btnMyQR:UIButton = UIButton()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawBottomItems()
    }

    
    func drawBottomItems()
    {
        if (bottomItemsView != nil) {
            
            return;
        }
        
        bottomItemsView = UIView(frame:CGRectMake( 0.0, CGRectGetMaxY(self.view.frame)-100,self.view.frame.size.width, 100 ) )
        
        
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        self.view .addSubview(bottomItemsView!)
        
        
        let size = CGSizeMake(65, 87);
        
        self.btnFlash = UIButton()
        btnFlash.bounds = CGRectMake(0, 0, size.width, size.height)
        btnFlash.center = CGPointMake(CGRectGetWidth(bottomItemsView!.frame)/2, CGRectGetHeight(bottomItemsView!.frame)/2)
        btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), forState:UIControlState.Normal)
        btnFlash.addTarget(self, action: "openOrCloseFlash", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.btnPhoto = UIButton()
        btnPhoto.bounds = btnFlash.bounds
        btnPhoto.center = CGPointMake(CGRectGetWidth(bottomItemsView!.frame)/4, CGRectGetHeight(bottomItemsView!.frame)/2)
        btnPhoto.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_photo_nor"), forState: UIControlState.Normal)
        btnPhoto.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_photo_down"), forState: UIControlState.Highlighted)
        btnPhoto.addTarget(self, action: "openPhotoAlbum", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.btnMyQR = UIButton()
        btnMyQR.bounds = btnFlash.bounds;
        btnMyQR.center = CGPointMake(CGRectGetWidth(bottomItemsView!.frame) * 3/4, CGRectGetHeight(bottomItemsView!.frame)/2);
        btnMyQR.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_myqrcode_nor"), forState: UIControlState.Normal)
        btnMyQR.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_myqrcode_down"), forState: UIControlState.Highlighted)
        btnMyQR.addTarget(self, action: "myCode", forControlEvents: UIControlEvents.TouchUpInside)
        
        bottomItemsView?.addSubview(btnFlash)
        bottomItemsView?.addSubview(btnPhoto)
        bottomItemsView?.addSubview(btnMyQR)
        
        self.view .addSubview(bottomItemsView!)
        
    }
    
    //开关闪光灯
    func openOrCloseFlash()
    {
        scanObj?.changeTorch();
        
        isOpenedFlash = !isOpenedFlash
        
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), forState:UIControlState.Normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), forState:UIControlState.Normal)
        }
    }
    
    func myCode()
    {
        let vc = MyCodeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }


}
