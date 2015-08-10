//
//  UDParseClient+Constants.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation

extension UDParseClient {
    
    public struct ErrorDomain {
        static public let ClientErrorDomain: String = "UDParseClientErrorDomain"
    }
    
    public struct ClassesKey {
        static public let StudentLocation: String = "StudentLocation"
    }
    
    public struct Constants {
        static public let Endpoint: String = "https://api.parse.com/1/classes/"
        
        static public let ApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static public let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    public struct RequestHeaderKeys {
        static public let ApplicationID: String = "X-Parse-Application-Id"
        static public let APIKey: String = "X-Parse-REST-API-Key"
    }
    
    public struct ParametersKey {
        static public let Where: String = "where"
        
        static public let Order: String = "order"
        static public let Limit: String = "limit"
        static public let Skip: String = "skip"
    }
    
    public struct ParametersValue {
        static public let createdAt: String = "createdAt"
        static public let firstName: String = "firstName"
        static public let lastName: String = "lastName"
        static public let latitude: String = "latitude"
        static public let longitude: String = "longitude"
        static public let mapString: String = "mapString"
        static public let mediaURL: String = "mediaURL"
        static public let objectId: String = "objectId"
        static public let uniqueKey: String = "uniqueKey"
        static public let updatedAt: String = "updatedAt"
    }

    public struct JSONResponseKeys {
        static public let ErrorMessage: String = "error"
        
        static public let Results: String = "results"
    }
}
