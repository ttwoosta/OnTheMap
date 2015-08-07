//
//  UDClient+Constants.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/5/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation

extension UDClient {
    
    public struct ErrorDomain {
        static public let ClientErrorDomain: String = "UDClientErrorDomain"
    }
    
    public struct Constants {
        static public let Endpoint: String = "https://www.udacity.com/api"
        
        static public let TokenCookieName: String = "XSRF-TOKEN"
        static public let TokenCookieHeaderField: String = "X-XSRF-TOKEN"
    }
    public struct Methods {
        static public let Session: String = "/session"
        static public let Users: String = "/users"
    }
    
    public struct JSONBodyKeys {
        static public let Username: String = "username"
        static public let Password: String = "password"
        
        static public let FacebookLogin: String = "facebook_mobile"
        static public let FacebookAccessToken: String = "access_token"
    }
    
    public struct JSONResponseKeys {
        static public let ErrorStatus: String = "status"
        static public let ErrorMessage: String = "error"
        
        static public let Results: String = "results"
        static public let User: String = "user"
        
        static public let SessionIDKeyPath: String = "session.id"
        static public let AccountIDKeyPath: String = "account.key"
    }
    
    
}