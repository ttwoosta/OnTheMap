//
//  UDClient.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/5/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import UIKit

public class UDClient: BaseClient {
    
    // shared session
    var session: NSURLSession
    
    public var userID: String!
    public var sessionID: String!

    //////////////////////////////////
    // MARK: Singleton
    /////////////////////////////////
    
    public class func sharedInstance() -> UDClient {
        struct Singleton {
            static var sharedInstance = UDClient()
        }
        return Singleton.sharedInstance
    }
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //////////////////////////////////
    // MARK: Udacity API
    /////////////////////////////////
    
    public class func getUdacityTokenCookie() -> NSHTTPCookie! {
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = sharedCookieStorage.cookies as! [NSHTTPCookie]
        for cookie in cookies {
            if cookie.name == Constants.TokenCookieName {
                return cookie
            }
        }
        return nil
    }
    
    public func taskForGETMethod(method: String, parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let URLString = Constants.Endpoint + method + UDClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }
    
    public func taskForPOSTMethod(method: String, parameters: [String: AnyObject]!, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let URLString = Constants.Endpoint + method + UDClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        URLRequest.HTTPMethod = "POST"
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
        
        // get token cookie from cookie storage
        // set header field with cookie value
        if let cookie = UDClient.getUdacityTokenCookie() {
            URLRequest.addValue(cookie.value!, forHTTPHeaderField: Constants.TokenCookieHeaderField)
        }
        
        var serializeError: NSError? = nil
        let postData = NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.allZeros, error: &serializeError)
        
        if let error = serializeError {
            completionHandler(result: nil, error: error)
            return nil
        }
        else {
            URLRequest.HTTPBody = postData
        }
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }
    
    public func taskForDELETEMethod(method: String, parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let URLString = Constants.Endpoint + method + UDClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        URLRequest.HTTPMethod = "DELETE"
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        
        // get token cookie from cookie storage
        // set header field with cookie value
        if let cookie = UDClient.getUdacityTokenCookie() {
            URLRequest.addValue(cookie.value!, forHTTPHeaderField: Constants.TokenCookieHeaderField)
        }
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }

    //////////////////////////////////
    // MARK: Shared methods
    /////////////////////////////////
    
    public func taskForRequest(URLRequest: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(URLRequest) {data, response, downloadError in
            
            var newData: NSData!
            if data != nil && data.length > 5 {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            }
            
            if let error = downloadError {
                let newError = UDClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else {
                let httpRes = response as! NSHTTPURLResponse
                
                if httpRes.statusCode == 200 || httpRes.statusCode == 201 {
                    UDClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
                }
                else {
                    let newError = UDClient.errorForData(newData, response: response, error: downloadError)
                    completionHandler(result: nil, error: newError)
                }
            }
        }
        
        return task
    }
    
    public class func errorForData(data: NSData!, response: NSURLResponse!, error: NSError!) -> NSError {
        
        if data != nil {
            if let parseResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
                if let errorCode = parseResult[JSONResponseKeys.ErrorStatus] as? Int {
                    if let errorMessage = parseResult[JSONResponseKeys.ErrorMessage] as? String {
                        let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                        return NSError(domain: ErrorDomain.ClientErrorDomain, code: errorCode, userInfo: userInfo)
                    }
                }
            }
        }
        
        // server doesn't known what error occurs
        // refer to response status code
        if let httpRes = response as? NSHTTPURLResponse {
            if httpRes.statusCode > 300 {
                return NSError(domain: ErrorDomain.ClientErrorDomain,
                    code: httpRes.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: NSHTTPURLResponse.localizedStringForStatusCode(httpRes.statusCode)])
            }
        }
        
        return error
    }
}