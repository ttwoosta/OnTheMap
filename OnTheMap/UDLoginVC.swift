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
    
    // login task (cancellation)
    var loginTask: NSURLSessionTask? = nil
    
    //////////////////////////////////
    // MARK: override methods
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
        
        // reset ui state
        self.loginState = .Ready
        
        // user sign in?
        if let cookie = UDClient.getUdacityTokenCookie() {
            presentMapViewController()
        }
        // automatically signin with facebook acc if token exist
        else if let token = FBSDKAccessToken.currentAccessToken() {
            loginAndPresentMapViewController(token.tokenString)
        }
    }
    
    //////////////////////////////////
    // MARK: Button actions
    /////////////////////////////////
    
    @IBAction func signupAction(sender: AnyObject) {
        let URL = NSURL(string: "https://www.udacity.com/account/auth#!/signin")
        let app = UIApplication.sharedApplication()
        app.openURL(URL!)
    }

    @IBAction func loginWithUserAndPasswordAction(sender: AnyObject) {
        
        // user did not enter username or password
        if txtFieldUsername.text.isEmpty || txtFieldPassword.text.isEmpty {
            let alert = UIAlertView(title: "Udacity login failed.", message: "Username and password are required.",
                delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        // hide login buttons and show spinner
        UIView.animateWithDuration(0.5) {
            self.loginState = .LoggingIn
        }
        
        // login with username and password
        loginTask = UDClient.loginAndGetCurrentUser(txtFieldUsername.text, password: txtFieldPassword.text) {[weak self] currentUser, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let user = currentUser {
                    // save current user and modally present mapVC
                    UDAppDelegate.sharedAppDelegate().currentUser = user
                    self?.presentMapViewController()
                }
                else {
                    self?.handleError(error!)
                }
            }
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        if let task = loginTask {
            task.cancel()
        }
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
    // MARK: UITextFieldDelegate
    /////////////////////////////////
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //////////////////////////////////
    // MARK: Shared methods
    /////////////////////////////////
    
    func loginAndPresentMapViewController(tokenString: String) {
        self.loginState = .LoggingIn
        
        loginTask = UDClient.loginAndGetCurrentUser(tokenString) {[weak self] currentUser, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let httpError = error {
                    self?.lblStatus.text = httpError.localizedDescription
                    self?.loginState = .Ready
                }
                else {
                    // save current user and modally present mapVC
                    UDAppDelegate.sharedAppDelegate().currentUser = currentUser
                    self?.presentMapViewController()
                }
            }
        }
    }
    
    func presentMapViewController() {
        performSegueWithIdentifier("mapViewController", sender: self)
    }
    
    func handleError(error: NSError?) {
        var title: String = ""
        var desc: String = ""
        
        if let httpError = error  {
            println(httpError)
            if httpError.code == 403 {
                title = httpError.localizedDescription
            }
            else {
                title = "Communications error"
                desc = httpError.localizedDescription
            }
        }
        else {
            title = "Unknow error occurs."
        }
        
        // reset ui state
        self.loginState = .Ready
        
        // set text for label
        lblStatus.text = title
        
        // notify user about the error
        let alert = UIAlertView(title: title, message: desc,
            delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    //////////////////////////////////
    // MARK: FBSDKLoginButtonDelegate
    /////////////////////////////////
    
    public func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        // login successfully
        if let tokenString = result.token.tokenString {
            loginAndPresentMapViewController(tokenString)
            return
        }
        
        // reset ui state
        self.loginState = .Ready
        
        // user cancel login
        if result.isCancelled {
            lblStatus.text = "Login is cancelled."
        }
        else {
            handleError(error)
        }
    }
    
    public func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        UDClient.logout() {[weak self] sessionID, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println(error)
                }
                self?.loginState = .Ready
            }
        }
    }
    
    
}
