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
        let results = appDelegate.hardCodedLocationData()
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
            pinView.animatesDrop = true
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

    
}

