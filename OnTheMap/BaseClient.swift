//
//  BaseClient.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit

public class BaseClient {
    
    public init() {

    }
    
    //////////////////////////////////
    //  MARK: Constants
    /////////////////////////////////
    
    struct HTTPHeaderKeys {
        static let Accept: String = "Accept"
        static let ContentType: String = "Content-Type"
    }
    
    struct HTTPHeaderValues {
        static let Json: String = "application/json"
    }
    
    //////////////////////////////////
    //  MARK: Helpers
    /////////////////////////////////
    
    public class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    public class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        }
        else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    public class func dictionaryToString(dict: [String: AnyObject]) -> String! {
        let json = NSJSONSerialization.dataWithJSONObject(dict, options: nil, error: nil)
        let str = NSString(data: json!, encoding: NSUTF8StringEncoding)
        return str as? String
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    public class func escapedParameters(parameters: [String : AnyObject!]!) -> String {
        
        if parameters == nil {
            return ""
        }
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            var stringValue: String = ""
            
            if value == nil {
                continue
            }
            else if let str = value as? String {
                stringValue = str
            }
            else if let dict = value as? [String: AnyObject] {
                stringValue = dictionaryToString(dict)
            }
            else { // convert Int to String
                stringValue = "\(value)"
            }
            
            
            /* Escape it */
            let queryCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
            let charSet = NSMutableCharacterSet()
            charSet.formUnionWithCharacterSet(queryCharSet)
            charSet.removeCharactersInString(":")
            
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(charSet)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
}
