//
//  ScanResultController.swift
//  swiftScan
//
//  Created by xialibing on 15/12/11.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit


class ScanResultController: UIViewController {

    @IBOutlet weak var codeImg: UIImageView!
    @IBOutlet weak var codeTypeLabel: UILabel!
    @IBOutlet weak var codeStringLabel: UILabel!
    @IBOutlet weak var concreteCodeImg: UIImageView!
    
    var codeResult:LBXScanResult?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        codeTypeLabel.text = ""
        codeStringLabel.text = ""

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        codeImg.image = codeResult?.imgScanned
        codeTypeLabel.text = "码的类型:" + (codeResult?.strBarCodeType)!
        codeStringLabel.text = "码的内容:" + (codeResult?.strScanned)!
        
        if codeImg.image != nil
        {
//            var rect = LBXScanWrapper.getConcreteCodeRectFromImage(srcCodeImage: codeImg.image!, codeResult: codeResult!)
//
//            if !rect.isEmpty
//            {
//                zoomRect(rect: &rect, srcImg: codeImg.image!)
//
//                let img2 = LBXScanWrapper.getConcreteCodeImage(srcCodeImage: codeImg.image!, rect: rect)
//
//                if (img2 != nil)
//                {
//                    concreteCodeImg.image = img2
//                }
//            }
            
        }
    }
    
    func zoomRect( rect:inout CGRect,srcImg:UIImage)
    {
        rect.origin.x -= 10
        rect.origin.y -= 10
        rect.size.width += 20
        rect.size.height += 20
        
        if rect.origin.x < 0
        {
            rect.origin.x = 0
        }
        
        if (rect.origin.y < 0)
        {
            rect.origin.y = 0
        }
        
        if (rect.origin.x + rect.size.width) > srcImg.size.width
        {
            rect.size.width = srcImg.size.width - rect.origin.x - 1
        }
        
        if (rect.origin.y + rect.size.height) > srcImg.size.height
        {
            rect.size.height = srcImg.size.height - rect.origin.y - 1
        }
        
        
    }
}




