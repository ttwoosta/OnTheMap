//
//  ParseClientTests.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import OnTheMap

class ParseClientTests: XCTestCase {

    //////////////////////////////////
    // Tests URL parameters
    /////////////////////////////////
    
    func test_get_method() {
        let parameters = [UDParseClient.ParametersKey.Where: ["uniqueKey": "1234"]]
        let task = UDParseClient.sharedInstance().taskForGETMethod(UDParseClient.ClassesKey.StudentLocation, parameters: parameters) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "GET")
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-Application-Id")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        let apiKey: String! = URLRequest?.valueForHTTPHeaderField("X-Parse-REST-API-Key")
        XCTAssertEqual(apiKey, "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        let URLString: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLString, "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D")
    }
    
    func test_post_method() {
        let parameters = [UDParseClient.ParametersKey.Where: ["uniqueKey": "1234"]]
        let body = ["uniqueKey": "1234", "key1": "value1"]
        let task = UDParseClient.sharedInstance().taskForPOSTMethod(UDParseClient.ClassesKey.StudentLocation, parameters: parameters, jsonBody: body) { result, error in  }
        XCTAssertNotNil(task)
        
        let URLRequest: NSURLRequest! = task.originalRequest
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
        let parameters = [UDParseClient.ParametersKey.Where: ["uniqueKey": "1234"]]
        let body = ["uniqueKey": "1234", "key1": "value1"]
        let task = UDParseClient.sharedInstance().taskForPUTMethod(UDParseClient.ClassesKey.StudentLocation, parameters: parameters, jsonBody: body) { result, error in  }
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
        
        UDParseClient.queryStudentLocations([UDParseClient.ParametersKey.Order: "createdAt", UDParseClient.ParametersKey.Limit: 5]) { results, error in
            
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
