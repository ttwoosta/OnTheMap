//
//  BaseClientTests.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/5/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import OnTheMap

class BaseClientTests: XCTestCase {

    var client: BaseClient! = BaseClient()
    
    //////////////////////////////////
    // Escaped parameters
    /////////////////////////////////
    
    func test_dict_to_string() {
        let dict = ["uniqueKey": "1234"]
        let str = BaseClient.dictionaryToString(dict)
        XCTAssertEqual(str, "{\"uniqueKey\":\"1234\"}")
    }
    
    func test_parameter_with_dict_value() {
        let dict: AnyObject = ["uniqueKey": "1234"]
        let parameters = ["where": dict]
        let str = BaseClient.escapedParameters(parameters)
        
        XCTAssertEqual(str, "?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_escaped_parameters() {
        let escapedParameters = BaseClient.escapedParameters(["key1": nil, "key2": "value2"])
        XCTAssertEqual(escapedParameters, "?key2=value2")
    }
    
    func test_escaped_parameters_int() {
        let escapedParameters = BaseClient.escapedParameters(["key1": 100, "key2": "value2"])
        XCTAssertEqual(escapedParameters, "?key1=100&key2=value2")

    }
    
    func test_escaped_parameters_can_be_nil() {
        let escapedParameters = BaseClient.escapedParameters(nil)
        XCTAssertEqual(escapedParameters, "")
    }
    
    //////////////////////////////////
    // Parse JSON with completion
    /////////////////////////////////
    
    func test_parse_json_with_completion_handler_fail() {
        let jsonData = "Dummy string".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        
        BaseClient.parseJSONWithCompletionHandler(jsonData, completionHandler: { result, error in
            
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
        
        BaseClient.parseJSONWithCompletionHandler(data, completionHandler: { result, error in
            
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
        
        BaseClient.parseJSONWithCompletionHandler(data, completionHandler: { result, error in
            
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
    
}
