//
//  UIDevice+Extensions.swift
//  swiftScan
//
//  Created by Bertug Yilmaz (Dogus Teknoloji) on 5/20/21.
//  Copyright © 2021 xialibing. All rights reserved.
//

import UIKit

extension UIDevice {
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
