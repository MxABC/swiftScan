//
//  LBXPermissions.swift
//  swiftScan https://github.com/MxABC/swiftScan
//
//  Created by xialibing on 15/12/15.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AssetsLibrary



class LBXPermissions: NSObject {

    //MARK: ---相机权限
    static func isGetCameraPermission()->Bool
    {
        
        let authStaus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if authStaus != AVAuthorizationStatus.denied
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    //MARK: ----获取相册权限
    static func isGetPhotoPermission()->Bool
    {
        var bResult = false
        if #available(iOS 8.0, *) {
            if ( PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.denied )
            {
                bResult = true
            }
        } else {
            if( ALAssetsLibrary.authorizationStatus() != ALAuthorizationStatus.denied )
            {
                bResult = true
            }
        }

        return bResult
    }
    
}
