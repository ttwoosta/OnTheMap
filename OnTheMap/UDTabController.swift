//
//  UDTabController.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/8/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class UDTabController: UITabBarController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the moc
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        moc = appDelegate.managedObjectContext!
        
        // setup location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func hardCodedLocation() -> [String : AnyObject] {
        return  [
                "firstName" : "Tu",
                "lastName" : "Tong",
                "latitude" : 27.1461248,
                "longitude" : -81.75676799999999,
                "mapString" : "Worcester, MA",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaLD8",
                "uniqueKey" : 872453750,
        ]
    }
    
    @IBAction func signOutAction(sender: AnyObject) {
        
    }
    
    @IBAction func addLocationAction(sender: AnyObject) {
//        let entity = NSEntityDescription.entityForName("UDLocation", inManagedObjectContext: moc)
//        
//        // student location object
//        var loc = UDLocation(entity: entity!, insertIntoManagedObjectContext: moc)
//        
//        loc.decodeWith(hardCodedLocation())
//        loc.updatedAt = NSDate()
//        loc.createdAt = NSDate()
//        //moc.save(nil)
        
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        let fetchRequest = NSFetchRequest(entityName: "UDLocation")
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let results = moc.executeFetchRequest(fetchRequest, error: nil) as! [UDLocation]
        
        for loc in results {
            moc.deleteObject(loc)
        }
        
        // populate locations
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        let data = appDelegate.hardCodedLocationData()
        UDLocation.locationsFromResults(data, moc: moc)
    }
    
    //////////////////////////////////
    // CLLocationManagerDelegate
    /////////////////////////////////
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        // set user location coord
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        appDelegate.userLocation = newLocation.coordinate
        
        // stop location manager update
        // only want one update
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        locationManager = nil
    }
}
