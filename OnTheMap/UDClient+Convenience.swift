//
//  UDClient+Convenience.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit

extension UDClient {
    
        
    //////////////////////////////////
    // Login
    /////////////////////////////////
    
    public class func login(userName: String, password: String, completionHandler: (sessionId: String!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let postBody = ["username": userName, "password": password]
        
        let task = sharedInstance().taskForPOSTMethod(Methods.Session, parameters: nil, jsonBody: postBody) { result, error in
            var sessionId: String!
            if error == nil {
                if let session_id = result.valueForKeyPath(JSONResponseKeys.SessionIDKeyPath) as? String {
                    sessionId = session_id
                    
                    // save session id and user id
                    self.sharedInstance().sessionID = session_id
                    if let userID = result.valueForKeyPath(JSONResponseKeys.AccountIDKeyPath) as? String {
                        self.sharedInstance().userID = userID
                    }
                }
            }
            
            completionHandler(sessionId: sessionId, error: error)
        }
        
        task.resume()
        return task
    }
    
    public class func login(facebookToken: String, completionHandler: (sessionId: String!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let postBody = ["facebook_mobile": ["access_token": facebookToken]]
        
        let task = sharedInstance().taskForPOSTMethod(Methods.Session, parameters: nil, jsonBody: postBody) { result, error in
            var sessionId: String!
            if error == nil {
                if let session_id = result.valueForKeyPath(JSONResponseKeys.SessionIDKeyPath) as? String {
                    sessionId = session_id
                    
                    // save session id and user id
                    self.sharedInstance().sessionID = session_id
                    if let userID = result.valueForKeyPath(JSONResponseKeys.AccountIDKeyPath) as? String {
                        self.sharedInstance().userID = userID
                    }
                }
            }
            
            completionHandler(sessionId: sessionId, error: error)
        }
        
        task.resume()
        return task
    }
    
    //////////////////////////////////
    // Logout
    /////////////////////////////////
    
    public class func logout(completionHandler: (sessionId: String!, error: NSError?) -> Void) -> NSURLSessionTask {

        let task = sharedInstance().taskForDELETEMethod(Methods.Session, parameters: nil) { result, error in
            var sessionId: String!
            if error == nil {
                if let session = result["session"] as? [String: AnyObject] {
                    if let session_id = session["id"] as? String {
                        sessionId = session_id
                        self.sharedInstance().userID = nil
                    }
                }
            }
            
            completionHandler(sessionId: sessionId, error: error)
        }
        
        // get the mutable url request
        let URLRequest = task.originalRequest as! NSMutableURLRequest
        
        // search for cookie
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            URLRequest.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        task.resume()
        return task
    }
    
    //////////////////////////////////
    // Logout
    /////////////////////////////////
    
    public class func getUserData(userID: String, completionHandler: (userData: [String: AnyObject]!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let method = Methods.Users + "/\(userID)"
        
        let task = sharedInstance().taskForGETMethod(method, parameters: nil) { result, error in
            var userInfo: [String: AnyObject]!
            if error == nil {
                if let info = result[JSONResponseKeys.User] as? [String: AnyObject] {
                    userInfo = info
                }
            }
            
            completionHandler(userData: userInfo, error: error)
        }
        
        task.resume()
        return task
    }
}
