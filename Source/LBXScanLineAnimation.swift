//
//  LBXScanLineAnimation.swift
//  swiftScan
//
//  Created by lbxia on 15/12/9.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit

class LBXScanLineAnimation: UIImageView {

    var isAnimationing = false
    var animationRect: CGRect = CGRectZero
    
    func startAnimatingWithRect(animationRect: CGRect, parentView: UIView, image: UIImage?)
    { 
        self.image = image
        self.animationRect = animationRect
        parentView.addSubview(self)
        
        self.hidden = false;
        
        isAnimationing = true;
        
        if image != nil
        {
            stepAnimation()
        }
        
    }
    
    func stepAnimation()
    {
        if (!isAnimationing) {
            return;
        }
        
        var frame:CGRect = animationRect;
        
        let hImg = self.image!.size.height * animationRect.size.width / self.image!.size.width;
        
        frame.origin.y -= hImg;
        frame.size.height = hImg;
        self.frame = frame;
        self.alpha = 0.0;
        
        UIView.animateWithDuration(1.4, animations: { () -> Void in
            
            self.alpha = 1.0;
            
            var frame = self.animationRect;
            let hImg = self.image!.size.height * self.animationRect.size.width / self.image!.size.width;
            
            frame.origin.y += (frame.size.height -  hImg);
            frame.size.height = hImg;
            
            self.frame = frame;
            
            }, completion:{ (value: Bool) -> Void in
                                
                self.performSelector(#selector(LBXScanLineAnimation.stepAnimation), withObject: nil, afterDelay: 0.3)
        })
        
    }
    
    func stopStepAnimating()
    {
        self.hidden = true;
        isAnimationing = false;
    }
    
    deinit
    {
        print("LBXScanLineAnimation deinit")
        stopStepAnimating()
    }

}





