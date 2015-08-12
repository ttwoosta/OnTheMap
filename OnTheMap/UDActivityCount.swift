//
//  UDActivityCount.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/12/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import UIKit

class UDActivityCount: UIActivityIndicatorView {
    
    var activityCount: UInt = 0
    
    func startActivity() {
        activityCount = activityCount + 1
    }
    
    func stopActivity() -> Bool {
        if activityCount > 1 {
            activityCount -= 1
            return true
        }
        else if activityCount == 1 {
            activityCount = 0
        }
        return false
    }
    
    func startOrStopActivity(value: Bool) -> Bool {
        if value {
            startActivity()
            return false
        }
        
        return stopActivity()
    }
}