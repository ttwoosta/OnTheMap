//
//  MKLocalSearch+StudentLocation.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

//
// xcdoc://?url=developer.apple.com/library/etc/redirect/xcode/ios/1048/samplecode/MapSearch/Introduction/Intro.html
//

import MapKit

extension MKLocalSearch {
    

    public class func search(searchKeyword: String!, userLocation: CLLocationCoordinate2D!, completionHandler: (mapItems: [MKMapItem]!, error: NSError?) -> Void) -> MKLocalSearch {
        
        // if user doesn't has location then
        // default location will be "Omaha, NE"
        var location = userLocation
        if userLocation == nil {
            location = CLLocationCoordinate2DMake(41.258652, -95.937195)
        }
        
        // setup the area spanned by the map region:
        // we use the delta values to indicate the desired zoom level of the map,
        //      (smaller delta values corresponding to a higher zoom level)
        let span = MKCoordinateSpanMake(0.112872, 0.109863)
        
        // initailize region with current location
        let region = MKCoordinateRegionMake(location, span)
        
        // create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.region = region
        
        // set search keyword
        searchRequest.naturalLanguageQuery = searchKeyword
        
        // start searching
        let localSearch = MKLocalSearch(request: searchRequest)
        
        localSearch.startWithCompletionHandler() { response, error in
            var mapItems: [MKMapItem]!
            if error == nil && response.mapItems.count > 0 {
                if let items = response.mapItems as? [MKMapItem] {
                    mapItems = items
                }
            }
            
            completionHandler(mapItems: mapItems, error: error)
        }
        
        return localSearch
    }
    
    
}
