//
//  LBXPermissions.swift
//  swiftScan
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
        
        let authStaus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if authStaus != AVAuthorizationStatus.Denied
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
        if  Float(UIDevice.currentDevice().systemVersion) < 8.0
        {
            if( ALAssetsLibrary.authorizationStatus() != ALAuthorizationStatus.Denied )
            {
                bResult = true
            }
        }
        else
        {
            if ( PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.Denied )
            {
                bResult = true
            }
        }
        
        return bResult
    }
    
}
