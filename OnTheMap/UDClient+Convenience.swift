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
        
        let postBody = [JSONBodyKeys.Username: userName, JSONBodyKeys.Password: password]
        
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
        
        let postBody = [JSONBodyKeys.FacebookLogin: [JSONBodyKeys.FacebookAccessToken: facebookToken]]
        
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
    
    public class func getTokenCookie() -> NSHTTPCookie! {
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == Constants.TokenCookieName {
                return cookie
            }
        }
        return nil
    }
    
    public class func logout(completionHandler: (sessionId: String!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let cookie = getTokenCookie()
        if cookie == nil {
            completionHandler(sessionId: "", error: nil)
            return nil
        }

        let task = sharedInstance().taskForDELETEMethod(Methods.Session, parameters: nil) { result, error in
            var sessionId: String!
            if error == nil {
                if let session_id = result.valueForKeyPath(JSONResponseKeys.SessionIDKeyPath) as? String {
                    sessionId = session_id
                    self.sharedInstance().userID = nil
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
                }
            }
            
            completionHandler(sessionId: sessionId, error: error)
        }
        
        // get the mutable url request
        let URLRequest = task.originalRequest as! NSMutableURLRequest
        URLRequest.setValue(cookie.value!, forHTTPHeaderField: Constants.TokenCookieHeaderField)
        
        task.resume()
        return task
    }
    
    //////////////////////////////////
    // Get user data
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
