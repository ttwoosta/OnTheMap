//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/4/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FirstViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var moc: NSManagedObjectContext!
    var frController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the moc
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        moc = appDelegate.managedObjectContext!
        
        // initializes fetch controller
        setupFetchedResultsController()
        
        // populate locations
        let results = hardCodedLocationData()
        UDLocation.locationsFromResults(results, moc: moc)
    }
    
    //////////////////////////////////
    // NSFetchedResultsControllerDelegate
    /////////////////////////////////
    
    func annotationForUniqueKey(uniqueKey: String) -> UDPointAnnotation! {
        for anno in mapView.annotations as! [UDPointAnnotation] {
            if anno.uniqueKey == uniqueKey {
                return anno
            }
        }
        return nil
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if let loc = anObject as? UDLocation {
            switch type {
            case .Insert:
                var anno = loc.pointAnnotation()
                anno.indexPath = newIndexPath
                mapView.addAnnotation(anno)
            case .Update:
                if let anno = annotationForUniqueKey(loc.uniqueKey) {
                    anno.coordinate = loc.annoCoordinate()
                    anno.title = loc.annoTitle()
                    anno.subtitle = loc.annoSubtitle()
                }
            case .Delete:
                if let anno = annotationForUniqueKey(loc.uniqueKey) {
                    mapView.removeAnnotation(anno)
                }
            default:
                println(loc)
            }
        }
        
        
    }
    
    //////////////////////////////////
    // MKMapViewDelegate
    /////////////////////////////////
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)!
            pinView.canShowCallout = true
            pinView.pinColor = .Red
            
            let btn = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            pinView.rightCalloutAccessoryView = btn
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            if let anno = annotationView.annotation as? UDPointAnnotation {
                // location
                if let loc = frController.objectAtIndexPath(anno.indexPath) as? UDLocation {
                    let app = UIApplication.sharedApplication()
                    app.openURL(loc.mediaURL)
                }
            }
        }
    }

    
    //////////////////////////////////
    // Convenience
    /////////////////////////////////
    
    func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "UDLocation")
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        frController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        frController.delegate = self
        frController.performFetch(nil)
    }
    
    func allLocation() -> [UDLocation] {
        let fetchRequest = NSFetchRequest(entityName: "UDLocation")
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let results = moc.executeFetchRequest(fetchRequest, error: nil) as! [UDLocation]
        return results
    }

    func hardCodedLocationData() -> [[String : AnyObject]] {
        return  [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : "872458750",
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : 35.1740471,
                "longitude" : -79.3922539,
                "mapString" : "Southern Pines, NC",
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : "225629858",
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : "236275855",
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : "996618664",
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
    }
}

