//
//  UDClient+Convenience.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit

extension UDClient {
    
    public func queryStudentLocations(parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let task = taskForGETMethod(ParseClassesKey.StudentLocation, parameters: parameters) { result, error in
            var locations: [[String: AnyObject]]!
            
            if error == nil {
                if let dictResponse = result as? [String: AnyObject] {
                    if let results = dictResponse[ParseJSONResponseKeys.Results] as? [[String: AnyObject]] {
                        locations = results
                    }
                }
            }
            println(result)
            completionHandler(result: locations, error: error)
        }
        task.resume()
        return task
    }
    
}
