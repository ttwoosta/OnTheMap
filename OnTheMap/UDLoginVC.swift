//
//  UDLoginVC.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class UDLoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    
    //////////////////////////////////
    // override methods
    /////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnFacebook.delegate = self
        
        if let token = FBSDKAccessToken.currentAccessToken() {
            println(token.tokenString)
        }
    }

    //////////////////////////////////
    // FBSDKLoginButtonDelegate
    /////////////////////////////////
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            println(result)
            println(result.token)
            println(result.token.tokenString)
        }
        else {
            println(error)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    
}
