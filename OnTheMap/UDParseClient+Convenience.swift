//
//  UDParseClient+Convenience.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/8/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation


extension UDParseClient {
    
    //////////////////////////////////
    // MARK: Query
    /////////////////////////////////
    
    public class func queryStudentLocations(parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let task = sharedInstance().taskForGETMethod(ClassesKey.StudentLocation, parameters: parameters) { result, error in
            var locations: [[String: AnyObject]]!
            
            if error == nil {
                if let dictResponse = result as? [String: AnyObject] {
                    if let results = dictResponse[JSONResponseKeys.Results] as? [[String: AnyObject]] {
                        locations = results
                    }
                }
            }
            completionHandler(result: locations, error: error)
        }
        task.resume()
        return task
    }
    
    public class func recurQueryStudentLocations(parameters: [String: AnyObject]!, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        var queryLimit = 50
        var querySkip = 0
        var mutableParams = parameters
        
        // query limit
        if let limit = parameters[ParametersKey.Limit] as? Int {
            queryLimit = limit
        }
        else {
            mutableParams[ParametersKey.Limit] = 50
        }
        
        // query skip
        if let skip = parameters[ParametersKey.Skip] as? Int {
            querySkip = skip
        }
        
        let task = queryStudentLocations(mutableParams) { result, error in
            if let queryResult = result as? [AnyObject] {
                if queryResult.count == queryLimit {
                    querySkip += queryLimit
                    mutableParams[ParametersKey.Skip] = querySkip
                    self.recurQueryStudentLocations(mutableParams, completionHandler: completionHandler)
                }
            }
            
            completionHandler(result: result, error: error)
        }
        
        return task
    }
    
    //////////////////////////////////
    // MARK: Single user location
    /////////////////////////////////

    public class func postStudentLocation(postBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let task = sharedInstance().taskForPOSTMethod(ClassesKey.StudentLocation, parameters: nil, jsonBody: postBody) { result, error in
            var mutableResult: [String: AnyObject]!
            
            // merge post body with result
            // for values objectId, createAt, updateAt
            if result != nil {
                mutableResult = postBody
                if let objectId = result[ParametersValue.objectId] as? String {
                    mutableResult[ParametersValue.objectId] = objectId
                    if let createdDateStr = result[ParametersValue.createdAt] as? String {
                        mutableResult[ParametersValue.createdAt] = createdDateStr
                        mutableResult[ParametersValue.updatedAt] = createdDateStr
                    }
                }
            }
            
            completionHandler(result: mutableResult, error: error)
        }
        
        task.resume()
        return task
    }
    
    public class func getStudentLocation(userID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let parameters = [ParametersKey.Where: [ParametersValue.uniqueKey: userID]]
        let task = sharedInstance().taskForGETMethod(ClassesKey.StudentLocation, parameters: parameters) { result, error in
            var locInfo: [String: AnyObject]!
            
            if result != nil {
                if let results = result[JSONResponseKeys.Results] as? [[String: AnyObject]] {
                    locInfo = results.first
                }
            }
            
            completionHandler(result: locInfo, error: error)
        }
        
        task.resume()
        return task
    }
    
    public class func updateStudentLocation(objectID: String, postBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let classPath = ClassesKey.StudentLocation + "/\(objectID)"
        
        let task = sharedInstance().taskForPUTMethod(classPath, parameters: nil, jsonBody: postBody) { result, error in
            var mutableResult: [String: AnyObject]!
            
            // merge post body with result
            // for values updateAt
            if result != nil {
                mutableResult = postBody
                mutableResult[ParametersValue.objectId] = objectID
                if let updatedDateStr = result[ParametersValue.updatedAt] as? String {
                    mutableResult[ParametersValue.updatedAt] = updatedDateStr
                }
            }
            
            completionHandler(result: mutableResult, error: error)
        }
        
        task.resume()
        return task
    }
    
    public class func deleteStudentLocation(objectID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
        let classPath = ClassesKey.StudentLocation + "/\(objectID)"
        
        let task = sharedInstance().taskForDELETEMethod(classPath, parameters: nil, completionHandler: completionHandler)
        task.resume()
        return task
    }
    
    //////////////////////////////////
    // MARK: Combine
    /////////////////////////////////
    
    public class func postOrUpdateStudentLocation(userID: String, postBody: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        getStudentLocation(userID) { result, error in
            if error != nil {
                completionHandler(result: result, error: error)
            }
            else if let objectID = result?[ParametersValue.objectId] as? String {
                self.updateStudentLocation(objectID, postBody: postBody, completionHandler: completionHandler)
            }
            else {
                self.postStudentLocation(postBody, completionHandler: completionHandler)
            }
        }
    }
}