//
//  UDLocationPostVC.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import MapKit

let UDLocationDidPostNotification = "UDLocationDidPostNotification"

class UDLocationPostVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    var place: MKMapItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var barItemPost: UIBarButtonItem!
    @IBOutlet weak var lblWarning: UILabel!
    
    var isURLValid: Bool = false {
        didSet {
            barItemPost.enabled = isURLValid
            lblWarning.hidden = isURLValid
        }
    }
    
    //////////////////////////////////
    // MARK: Override methods
    /////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get current location and update textField to previous entered url
        let userID = UDAppDelegate.sharedAppDelegate().currentUser?.userID
        let moc = UDAppDelegate.sharedAppDelegate().managedObjectContext!
        if let obj = UDLocation.studentLocationForUniqueKey(userID!, inManagedObjectContext: moc) {
            textFieldURL.text = obj.mediaURLString
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // disable post
        self.isURLValid = false
        
        // add new place to map view
        mapView.addAnnotation(place.placemark)
        
        // focus on url textField
        textFieldURL.becomeFirstResponder()
    }
    
    //////////////////////////////////
    // MARK: MKMapViewDelegate
    /////////////////////////////////
    
    func textFieldDidEndEditing(textField: UITextField) {
        // hide keyboard
        textField.resignFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if let URL = NSURL(string: textField.text) {
            self.isURLValid = true
        }
        else {
            self.isURLValid = false
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // hide keyboard
        textField.resignFirstResponder()
        
        
        return true
    }
    
    //////////////////////////////////
    // MARK: MKMapViewDelegate
    /////////////////////////////////
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)!
            pinView.canShowCallout = true
            pinView.animatesDrop = true
            pinView.pinColor = .Purple
            
            let btn = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            pinView.rightCalloutAccessoryView = btn
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        mapView.selectAnnotation(place.placemark, animated: true)
    }
    
    //////////////////////////////////
    // MARK: Post action
    /////////////////////////////////
    
    @IBAction func postAction(sender: AnyObject) {
        
        // get current user information
        let currentUser = UDAppDelegate.sharedAppDelegate().currentUser
        
        // managed object context
        let moc = UDAppDelegate.sharedAppDelegate().managedObjectContext
        
        // initial post information
        let postInfo = currentUser?.createPostInfoFor(place, URL: textFieldURL.text)
        println(postInfo)
        
        let userID = currentUser?.userID
        
        UDParseClient.postOrUpdateStudentLocation(userID!, postBody: postInfo!) {[weak self] result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    let alert = UIAlertView(title: "Communications error", message: error?.localizedDescription,
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                else { // post completed with no error
                    
                    // dismiss view controller
                    self?.dismissViewControllerAnimated(true) {
                        
                        // create or update current location
                        UDLocation.createOrUpdateStudentLocation(userID!,
                            decodeDict: result as! [String: AnyObject],
                            inManagedObjectContext: moc!)
                    }
                }
            }
        }
    }
}

