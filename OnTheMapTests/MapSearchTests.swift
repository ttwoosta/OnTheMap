//
//  MapSearchTests.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import XCTest
import OnTheMap
import MapKit

class MapSearchTests: XCTestCase {

    var userLocation: CLLocationCoordinate2D!
    
    override func setUp() {
        super.setUp()
        
        userLocation = CLLocationCoordinate2DMake(37.331565189999999, -122.03057969)
    }
    
    func test_local_search() {
        
        // setup the area spanned by the map region:
        // we use the delta values to indicate the desired zoom level of the map,
        //      (smaller delta values corresponding to a higher zoom level)
        let span = MKCoordinateSpanMake(0.112872, 0.109863)
        
        // initailize region with current location
        let region = MKCoordinateRegionMake(userLocation, span)
        
        // create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.region = region
        
        // set search keyword
        searchRequest.naturalLanguageQuery = "Las Vegas, NV"
        
        let expectation = self.expectationWithDescription(nil)
        
        // start searching
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.startWithCompletionHandler() { response, error in
            
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            
            println(response)
            
            if let mapItem = response.mapItems[0] as? MKMapItem {
                XCTAssertFalse(mapItem.isCurrentLocation)
                XCTAssertEqual(mapItem.name, "Las Vegas, NV")
                XCTAssertEqual(mapItem.placemark.title, "Las Vegas, NV, United States")
                XCTAssertEqual(mapItem.placemark.coordinate.latitude, 36.16920200)
                XCTAssertEqual(mapItem.placemark.coordinate.longitude, -115.14059700)
                XCTAssertEqual(mapItem.url.absoluteString!, "http://en.wikipedia.org/wiki/Las_Vegas")
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func test_local_search_with_keyword_usr_location() {
        
        let expectation = self.expectationWithDescription(nil)
        
        MKLocalSearch.search("Las Vegas", userLocation: userLocation) { mapItems, error in
            XCTAssertNotNil(mapItems)
            XCTAssertNil(error)
            
            if let mapItem = mapItems.first {
                XCTAssertFalse(mapItem.isCurrentLocation)
                XCTAssertEqual(mapItem.name, "Las Vegas, NV")
                XCTAssertEqual(mapItem.placemark.title, "Las Vegas, NV, United States")
                XCTAssertEqual(mapItem.placemark.coordinate.latitude, 36.16920200)
                XCTAssertEqual(mapItem.placemark.coordinate.longitude, -115.14059700)
                XCTAssertEqual(mapItem.url.absoluteString!, "http://en.wikipedia.org/wiki/Las_Vegas")
            }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

}
