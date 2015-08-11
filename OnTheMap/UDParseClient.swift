//
//  UDParseClient.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit

public class UDParseClient: BaseClient {
    // shared session
    var session: NSURLSession
    
    //////////////////////////////////
    // MARK: Singleton
    /////////////////////////////////
    
    public class func sharedInstance() -> UDParseClient {
        struct Singleton {
            static var sharedInstance = UDParseClient()
        }
        return Singleton.sharedInstance
    }
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    //////////////////////////////////
    // MARK: API
    /////////////////////////////////
    
    public func taskForPOSTMethod(classes: String, parameters: [String: AnyObject]!, jsonBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask! {
        
        let URLString = Constants.Endpoint + classes + UDParseClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        URLRequest.HTTPMethod = "POST"
        URLRequest.addValue(Constants.ApplicationID, forHTTPHeaderField: RequestHeaderKeys.ApplicationID)
        URLRequest.addValue(Constants.APIKey, forHTTPHeaderField: RequestHeaderKeys.APIKey)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
        
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
        
        let URLString = Constants.Endpoint + classes + UDParseClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        URLRequest.HTTPMethod = "PUT"
        URLRequest.addValue(Constants.ApplicationID, forHTTPHeaderField: RequestHeaderKeys.ApplicationID)
        URLRequest.addValue(Constants.APIKey, forHTTPHeaderField: RequestHeaderKeys.APIKey)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
        
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
    
    public func taskForGETMethod(classes: String, parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let URLString = Constants.Endpoint + classes + UDParseClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
        URLRequest.addValue(Constants.ApplicationID, forHTTPHeaderField: RequestHeaderKeys.ApplicationID)
        URLRequest.addValue(Constants.APIKey, forHTTPHeaderField: RequestHeaderKeys.APIKey)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }
    
    public func taskForDELETEMethod(classes: String, parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let URLString = Constants.Endpoint + classes + UDParseClient.escapedParameters(parameters)
        let URL = NSURL(string: URLString)!
        let URLRequest = NSMutableURLRequest(URL: URL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        URLRequest.HTTPMethod = "DELETE"
        URLRequest.addValue(Constants.ApplicationID, forHTTPHeaderField: RequestHeaderKeys.ApplicationID)
        URLRequest.addValue(Constants.APIKey, forHTTPHeaderField: RequestHeaderKeys.APIKey)
        URLRequest.addValue(HTTPHeaderValues.Json, forHTTPHeaderField: HTTPHeaderKeys.Accept)
        
        return taskForRequest(URLRequest, completionHandler: completionHandler)
    }
    
    //////////////////////////////////
    // MARK: Shared methods
    /////////////////////////////////
    
    public func taskForRequest(URLRequest: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let task = session.dataTaskWithRequest(URLRequest) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = UDParseClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            }
            else {
                let httpRes = response as! NSHTTPURLResponse
                
                if httpRes.statusCode == 200 || httpRes.statusCode == 201 {
                    UDParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                }
                else {
                    let newError = UDParseClient.errorForData(data, response: response, error: downloadError)
                    completionHandler(result: nil, error: newError)
                }
            }
        }
        
        return task
    }
    
    public class func errorForData(data: NSData!, response: NSURLResponse!, error: NSError!) -> NSError {
        
        if data != nil {
            if let Result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
                if let errorMessage = Result[JSONResponseKeys.ErrorMessage] as? String {
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
