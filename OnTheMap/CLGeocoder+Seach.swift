//
//  CLGeocoder+Seach.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/12/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import MapKit


extension CLGeocoder {
    
    public class func search(keyword: String, completionHandler: (mapItems: [MKMapItem]!, error: NSError?) -> Void) -> CLGeocoder {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(keyword) { result, error in
            var items: [MKMapItem]!
            if let placemarks = result as? [CLPlacemark] {
                items = [MKMapItem]()
                for pl in placemarks {
                    let pm = MKPlacemark(coordinate: pl.location.coordinate, addressDictionary: pl.addressDictionary)
                    let mapItem = MKMapItem(placemark: pm)
                    items.append(mapItem)
                }
            }
            completionHandler(mapItems: items, error: error)
        }
        return geocoder
    }
    
}
