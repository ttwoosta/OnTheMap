//
//  UDClient.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/5/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import UIKit

public class UDClient {
    
    // shared session
    var session: NSURLSession
    
    public class func sharedInstance() -> UDClient {
        struct Singleton {
            static var sharedInstance = UDClient()
        }
        return Singleton.sharedInstance
    }
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    public func taskForPOSTMethod(classes: String, parameters: [String: AnyObject]!, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let URLString = ParseConstants.Endpoint + classes + UDClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        URLRequest.HTTPMethod = "POST"
        URLRequest.addValue(ParseConstants.ApplicationID, forHTTPHeaderField: ParseRequestHeaderKeys.ApplicationID)
        URLRequest.addValue(ParseConstants.APIKey, forHTTPHeaderField: ParseRequestHeaderKeys.APIKey)
        URLRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        URLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    
    public func taskForPUTMethod(classes: String, parameters: [String: AnyObject]!, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let task = taskForPOSTMethod(classes, parameters: parameters, jsonBody: jsonBody, completionHandler: completionHandler)
        let URLRequest = task.originalRequest as! NSMutableURLRequest
        URLRequest.HTTPMethod = "PUT"
        
        return task
    }
    
    public func taskForGETMethod(classes: String, parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let URLString = ParseConstants.Endpoint + classes + UDClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        URLRequest.addValue(ParseConstants.ApplicationID, forHTTPHeaderField: ParseRequestHeaderKeys.ApplicationID)
        URLRequest.addValue(ParseConstants.APIKey, forHTTPHeaderField: ParseRequestHeaderKeys.APIKey)
        URLRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }
    
    public func taskForRequest(URLRequest: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(URLRequest) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = UDClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else {
                let httpRes = response as! NSHTTPURLResponse
                
                if httpRes.statusCode == 200 || httpRes.statusCode == 201 {
                    UDClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
                else {
                    let newError = UDClient.errorForData(data, response: response, error: downloadError)
                    completionHandler(result: nil, error: newError)
                }
            }
        }
        
        return task
    }
    
    public class func errorForData(data: NSData!, response: NSURLResponse!, error: NSError!) -> NSError {
        
        if data != nil {
            if let parseResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
                if let errorMessage = parseResult[ParseJSONResponseKeys.StatusMessage] as? String {
                    let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                    return NSError(domain: ErrorDomain.ClientErrorDomain, code: 1, userInfo: userInfo)
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