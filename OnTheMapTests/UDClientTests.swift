//
//  UDClientTests.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/5/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import OnTheMap

class UDClientTests: XCTestCase {

    var client: UDClient?
    
    override func setUp() {
        super.setUp()
        
        client = UDClient.sharedInstance()
    }
    
    //////////////////////////////////
    // Escaped parameters
    /////////////////////////////////
    
    func test_dict_to_string() {
        let dict = ["uniqueKey": "1234"]
        let str = UDClient.dictionaryToString(dict)
        XCTAssertEqual(str, "{\"uniqueKey\":\"1234\"}")
    }
    
    func test_parameter_with_dict_value() {
        let dict: AnyObject = ["uniqueKey": "1234"]
        let parameters = ["where": dict]
        let str = UDClient.escapedParameters(parameters)
        
        XCTAssertEqual(str, "?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_escaped_parameters() {
        let escapedParameters = UDClient.escapedParameters(["key1": nil, "key2": "value2"])
        XCTAssertEqual(escapedParameters, "?key2=value2")
    }
    
    func test_escaped_parameters_int() {
        let escapedParameters = UDClient.escapedParameters(["key1": 100, "key2": "value2"])
        XCTAssertEqual(escapedParameters, "?key1=100&key2=value2")

    }
    
    func test_escaped_parameters_can_be_nil() {
        let escapedParameters = UDClient.escapedParameters(nil)
        XCTAssertEqual(escapedParameters, "")
    }
    
    //////////////////////////////////
    // Parse JSON with completion
    /////////////////////////////////
    func test_parse_json_with_completion_handler_fail() {
        let jsonData = "Dummy string".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        
        UDClient.parseJSONWithCompletionHandler(jsonData, completionHandler: { result, error in
            
            XCTAssertNil(result)
            
            let err = error!
            XCTAssertNotNil(err, "Error cannot be nil")
            XCTAssertEqual(err.domain, NSCocoaErrorDomain)
            XCTAssertEqual(err.code, 3840)
            XCTAssertEqual(err.localizedDescription, "The operation couldn’t be completed. (Cocoa error 3840.)")
        })
    }
    
    func test_parse_json_with_completion_handler_pass_dict() {
        
        let object = ["key1": "value1", "key2": "value2"]
        let data = NSJSONSerialization.dataWithJSONObject(object, options: nil, error: nil)!
        
        UDClient.parseJSONWithCompletionHandler(data, completionHandler: { result, error in
            
            XCTAssertNil(error)
            
            if let dict = result as? [String: String] {
                XCTAssertEqual(dict["key1"]!, "value1")
                XCTAssertEqual(dict["key2"]!, "value2")
            }
            else {
                XCTAssert(false, "Result isn't a dictionary")
            }
        })
        
    }
    
    func test_parse_json_with_completion_handler_pass_array() {
        
        let object = ["value1", "value2"]
        let data = NSJSONSerialization.dataWithJSONObject(object, options: nil, error: nil)!
        
        UDClient.parseJSONWithCompletionHandler(data, completionHandler: { result, error in
            
            XCTAssertNil(error)
            
            if let array = result as? [String] {
                XCTAssertEqual(array[0], "value1")
                XCTAssertEqual(array[1], "value2")
            }
            else {
                XCTAssert(false, "Result isn't an array")
            }
        })
        
    }
    
    //////////////////////////////////
    // Tests URL parameters
    /////////////////////////////////

    func test_get_method() {
        let parameters = [UDClient.ParseParametersKey.Where: ["uniqueKey": "1234"]]
        let task = client?.taskForGETMethod(UDClient.ParseClassesKey.StudentLocation, parameters: parameters) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task?.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "GET")
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_post_method() {
        let parameters = [UDClient.ParseParametersKey.Where: ["uniqueKey": "1234"]]
        let body = ["uniqueKey": "1234", "key1": "value1"]
        let task = client?.taskForPOSTMethod(UDClient.ParseClassesKey.StudentLocation, parameters: parameters, jsonBody: body) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task?.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "POST")
        XCTAssertNotNil(URLRequest.HTTPBody)
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let contentType: String! = URLRequest.valueForHTTPHeaderField("Content-Type")
        XCTAssertEqual(contentType, "application/json")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_put_method() {
        let parameters = [UDClient.ParseParametersKey.Where: ["uniqueKey": "1234"]]
        let body = ["uniqueKey": "1234", "key1": "value1"]
        let task = client?.taskForPUTMethod(UDClient.ParseClassesKey.StudentLocation, parameters: parameters, jsonBody: body) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task?.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "PUT")
        XCTAssertNotNil(URLRequest.HTTPBody)
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let contentType: String! = URLRequest.valueForHTTPHeaderField("Content-Type")
        XCTAssertEqual(contentType, "application/json")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    //////////////////////////////////
    // Retrieves object
    /////////////////////////////////
    
    func test_query_student_locations() {
        let expectation = self.expectationWithDescription(nil)
        
        client?.queryStudentLocations([UDClient.ParseParametersKey.Order: "createdAt", UDClient.ParseParametersKey.Limit: 5]) { results, error in
            
            if error == nil {
                println(results)
            }
            else {
                println(error)
            }
            
            XCTAssertNotNil(results)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
