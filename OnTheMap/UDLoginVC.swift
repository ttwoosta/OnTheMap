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

public enum LoginVCState: Int {
    case Ready, LoggingIn, LoggingOut
}

public class UDLoginVC: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    public var loginState: LoginVCState = .Ready {
        didSet {
            switch loginState {
            case .Ready:
                viewSpinner.alpha = 0
                viewMain.alpha = 1
                spinner.stopAnimating()
            case .LoggingIn:
                lblStatus.text = ""
                viewMain.alpha = 0
                viewSpinner.alpha = 1
                spinner.startAnimating()
            case .LoggingOut:
                lblStatus.text = ""
                viewMain.alpha = 0
                viewSpinner.alpha = 1
                spinner.startAnimating()
            }
            
        }
    }
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewSpinner: UIView!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    // MainView's sub views
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!

    // SpinnerView's sub views
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var btnCancel: UIButton!
    
    //////////////////////////////////
    // override methods
    /////////////////////////////////
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // setup views
        lblStatus.text = ""
        self.loginState = .Ready
        
        // facebook login delegate
        btnFacebook.delegate = self
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // automaticlly login with facebook token
        //if let token = FBSDKAccessToken.currentAccessToken() {
        //    loginAndPresentMapViewController(token.tokenString)
        //}
    }
    
    //////////////////////////////////
    // Button actions
    /////////////////////////////////

    @IBAction func loginWithUserAndPasswordAction(sender: AnyObject) {
        UIView.animateWithDuration(0.5) {
            self.loginState = .LoggingIn
        }
        
        UDClient.loginAndGetCurrentUser(txtFieldUsername.text, password: txtFieldPassword.text) { currentUser, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let httpError = error {
                    self.lblStatus.text = httpError.localizedDescription
                    self.loginState = .Ready
                }
                else {
                    // save current user and modally present mapVC
                    UDAppDelegate.sharedAppDelegate().currentUser = currentUser
                    self.presentMapViewController()
                }
            }
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        UIView.animateWithDuration(0.5) {
            self.loginState = .Ready
        }
    }
    
    @IBAction func loginWithFacebookAction(sender: AnyObject) {
        UIView.animateWithDuration(0.5) {
            self.loginState = .LoggingIn
        }
    }
    
    //////////////////////////////////
    // FBSDKLoginButtonDelegate
    /////////////////////////////////
    
    func loginAndPresentMapViewController(tokenString: String) {
        self.loginState = .LoggingIn
        
        UDClient.loginAndGetCurrentUser(tokenString) { currentUser, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let httpError = error {
                    self.lblStatus.text = httpError.localizedDescription
                    self.loginState = .Ready
                }
                else {
                    // save current user and modally present mapVC
                    UDAppDelegate.sharedAppDelegate().currentUser = currentUser
                    self.presentMapViewController()
                }
            }
        }
    }
    
    func presentMapViewController() {
        performSegueWithIdentifier("mapViewController", sender: self)
    }
    
    //////////////////////////////////
    // FBSDKLoginButtonDelegate
    /////////////////////////////////
    
    public func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let httpError = error {
            self.lblStatus.text = httpError.localizedDescription
            self.loginState = .Ready
        }
        else if result.isCancelled {
            lblStatus.text = "Login is cancelled."
            self.loginState = .Ready
        }
        else if let tokenString = result.token.tokenString {
            loginAndPresentMapViewController(tokenString)
        }
        else {
            lblStatus.text = "Unknow error occurs."
            self.loginState = .Ready
        }
    }
    
    public func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        UDClient.logout() { sessionID, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println(error)
                }
                self.loginState = .Ready
            }
        }
    }
    
    
}
