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
    // MARK: Login
    /////////////////////////////////
    
    public class func login(userName: String, password: String, completionHandler: (sessionId: String!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let postBody = [JSONBodyKeys.Udacity: [JSONBodyKeys.Username: userName, JSONBodyKeys.Password: password]]
        
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
    // MARK: Logout
    /////////////////////////////////
    
    public class func logout(completionHandler: (sessionId: String!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let task = sharedInstance().taskForDELETEMethod(Methods.Session, parameters: nil) { result, error in
            var sessionId: String!
            if error == nil {
                if let session_id = result.valueForKeyPath(JSONResponseKeys.SessionIDKeyPath) as? String {
                    sessionId = session_id
                    self.sharedInstance().userID = nil
                    
                    // if signout successfully, delete cookie
                    if let cookie = self.getUdacityTokenCookie() {
                        NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
                    }
                }
            }
            
            completionHandler(sessionId: sessionId, error: error)
        }
        
        task.resume()
        return task
    }
    
    //////////////////////////////////
    // MARK: Get user data
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
    
    
    public class func getCurrentUser(completionHandler: (currentUser: UDCurrentUser!, error: NSError?) -> Void) -> NSURLSessionTask {
        let task = getUserData("me") { userData, error in
            var user: UDCurrentUser!
            
            if userData != nil {
                if let userID = userData[JSONResponseKeys.UserID] as? String {
                    user = UDCurrentUser(userID: userID)
                    user.firstName = userData[JSONResponseKeys.FirstName] as! String
                    user.lastName = userData[JSONResponseKeys.LastName] as! String
                }
            }
            
            completionHandler(currentUser: user, error: error)
        }
        
        return task
    }
    
    //////////////////////////////////
    // MARK: Combine login and get user data
    /////////////////////////////////
    
    public class func loginAndGetCurrentUser(userName: String, password: String, completionHandler: (currentUser: UDCurrentUser!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let task = UDClient.login(userName, password: password) { sessionID, error in
            if error == nil {
                UDClient.getCurrentUser(completionHandler)
            }
            else {
                completionHandler(currentUser: nil, error: error)
            }
        }
        return task
    }
    
    public class func loginAndGetCurrentUser(facebookToken: String, completionHandler: (currentUser: UDCurrentUser!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let task = UDClient.login(facebookToken) { sessionID, error in
            if error == nil {
                UDClient.getCurrentUser(completionHandler)
            }
            else {
                completionHandler(currentUser: nil, error: error)
            }
        }
        return task
    }
}
