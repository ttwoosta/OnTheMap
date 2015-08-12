//
//  UDSessionTests.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import OnTheMap
import FBSDKCoreKit
import FBSDKLoginKit

class UDSessionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func test_login_with_fb_access_token() {
        let token = FBSDKAccessToken.currentAccessToken()
        XCTAssertNotNil(token)
        
        let accessToken = token.tokenString
        XCTAssertNotNil(accessToken)
        
        let expectation = self.expectationWithDescription(nil)
        
        UDClient.login(accessToken) { sessionId, error in
            XCTAssertNotNil(sessionId)
            XCTAssertNil(error)
            
            XCTAssertNotNil(UDClient.sharedInstance().userID)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func test_login_with_user_pass_fail() {
        let expectation = self.expectationWithDescription(nil)
        
        UDClient.login("unknown_user@gmail.com", password: "123") { sessionId, error in
            println(error)
            XCTAssertNil(sessionId)
            XCTAssertNotNil(error)
            let err: NSError! = error
            XCTAssertEqual(err.code, 400)
            XCTAssertEqual(err.localizedDescription, "Did not specify exactly one credential.")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func test_logout() {
        let expectation = self.expectationWithDescription(nil)
        
        let task = UDClient.logout() { sessionId, error in
            XCTAssertNotNil(sessionId)
            XCTAssertNil(error)
            println(sessionId)
            
            XCTAssertNil(UDClient.sharedInstance().userID)
            expectation.fulfill()
        }
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "POST")
        XCTAssertNotNil(URLRequest.HTTPBody)
        
        let appID: String! = URLRequest?.valueForHTTPHeaderField("X-XSRF-TOKEN")
        XCTAssertEqual(appID, "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
        
        self.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func test_get_user_info() {
        let expectation = self.expectationWithDescription(nil)
        
        let task = UDClient.getUserData("3903878747") { userData, error in
            println(userData)
            XCTAssertNotNil(userData)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "GET")
        
        let URLStr: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLStr, "https://www.udacity.com/api/users/3903878747")
        
        self.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func test_get_current_user() {
        let expectation = self.expectationWithDescription(nil)
        
        let task = UDClient.getCurrentUser() { user, error in
            println(user)
            
            XCTAssertNotNil(user.firstName)
            XCTAssertNotNil(user.lastName)
            XCTAssertNotNil(user.userID)
            
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        let URLRequest: NSURLRequest! = task.originalRequest
        XCTAssertEqual(URLRequest.HTTPMethod!, "GET")
        
        let URLStr: String! = URLRequest.URL?.absoluteString
        XCTAssertEqual(URLStr, "https://www.udacity.com/api/users/me")
        
        self.waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    

}