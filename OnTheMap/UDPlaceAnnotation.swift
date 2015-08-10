//
//  UDPlaceAnnotation.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import Foundation
import MapKit

class UDPlaceAnnotation: NSObject, MKAnnotation {
    
    // Center latitude and longitude of the annotation view.
    // The implementation of this property must be KVO compliant.
    var coordinate: CLLocationCoordinate2D
    
    // Title and subtitle for use by selection UI.
    var title: String!
    var subtitle: String!
    
    var URL: NSURL!
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
}