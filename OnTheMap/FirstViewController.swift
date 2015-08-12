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
    
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the moc
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        moc = appDelegate.managedObjectContext!
        
        // current user id
        currentUserID = appDelegate.currentUser?.userID
        
        // initializes fetch controller
        setupFetchedResultsController()
        
        // populate locations
        let parameters: [String: AnyObject] = [UDParseClient.ParametersKey.Order: "-\(UDParseClient.ParametersValue.updatedAt)"]
        
        UDParseClient.recurQueryStudentLocations(parameters) {[weak self] result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    let alert = UIAlertView(title: "Communications error", message: error?.localizedDescription,
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                else if let context = self?.moc {
                    if let results = result as? [[String: AnyObject]] {
                        UDLocation.locationsFromResults(results, moc: context)
                    }
                }
            }
        
        }
    }
    
    //////////////////////////////////
    // MARK: NSFetchedResultsControllerDelegate
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
                if loc.uniqueKey == currentUserID {
                    anno.isCurrentUserLocation = true
                }
                mapView.addAnnotation(anno)
            case .Update:
                if let anno = annotationForUniqueKey(loc.uniqueKey) {
                    // update location
                    anno.coordinate = loc.annoCoordinate()
                    anno.title = loc.annoTitle()
                    anno.subtitle = loc.annoSubtitle()
                    anno.indexPath = newIndexPath
                    
                    // animated select new location
                    mapView.selectAnnotation(anno, animated: true)
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
    // MARK: MKMapViewDelegate
    /////////////////////////////////
    
    func locationObjcForAnnotation(anno: MKAnnotation) -> UDLocation! {
        if let anno = anno as? UDPointAnnotation {
            // location
            if let loc = frController.objectAtIndexPath(anno.indexPath) as? UDLocation {
                return loc
            }
        }
        return nil
    }
    
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
            pinView.pinColor = .Red
        }
        
        // highlight current location with purple color
        if let anno = annotation as? UDPointAnnotation {
            if anno.isCurrentUserLocation {
                pinView.pinColor = .Purple
                pinView.setSelected(true, animated: true)
            }
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
    // MARK: Convenience
    /////////////////////////////////
    
    func setupFetchedResultsController() {
        
        // create fetch request for UDLocation objects
        // sort by date updated
        let fetchRequest = NSFetchRequest(entityName: UDLocation.kUDLocation)
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: UDLocation.JSONKeys.updatedAt, ascending: false)]
        
        // initialize fetched result controller
        frController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        // listen to frc event
        frController.delegate = self
        
        // start fetching object
        frController.performFetch(nil)
    }
    
}

