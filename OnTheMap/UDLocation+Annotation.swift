//
//  UDLocation+Annotation.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/6/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import MapKit


extension UDLocation {
    
    public func annoCoordinate() -> CLLocationCoordinate2D {
        // create 2D coordinate
        let lat = CLLocationDegrees(latitude.doubleValue)
        let long = CLLocationDegrees(longitude.doubleValue)
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        return coordinate
    }
    
    public func annoTitle() -> String {
        return "\(firstName) \(lastName)"
    }
    
    public func annoSubtitle() -> String {
        return "\(createdAt)"
    }
    
    public func pointAnnotation() -> UDPointAnnotation {
        
        // create a returned point annnotation
        var annotation = UDPointAnnotation()
        annotation.coordinate = annoCoordinate()
        annotation.title = annoTitle()
        annotation.subtitle = annoSubtitle()
        annotation.uniqueKey = uniqueKey
        
        return annotation
    }
    
}