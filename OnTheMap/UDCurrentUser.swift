//
//  UDCurrentUser.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import MapKit

public class UDCurrentUser: Printable {
    
    public var firstName: String!
    public var lastName: String!
    public var userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    public func createPostInfoFor(place: MKMapItem, URL: String) -> [String: AnyObject] {
        var info = [String: AnyObject]()
        info[UDParseClient.ParametersValue.uniqueKey] = userID
        info[UDParseClient.ParametersValue.firstName] = firstName
        info[UDParseClient.ParametersValue.lastName] = lastName
        info[UDParseClient.ParametersValue.latitude] = place.placemark.coordinate.latitude
        info[UDParseClient.ParametersValue.longitude] = place.placemark.coordinate.longitude
        info[UDParseClient.ParametersValue.mapString] = place.placemark.title
        info[UDParseClient.ParametersValue.mediaURL] = URL
        
        return info
    }
    
    public var description: String {
        get {
            return "<User: \(userID), name: \(firstName) \(lastName)>"
        }
    }
}
