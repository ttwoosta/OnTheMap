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
    // Override methods
    /////////////////////////////////
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // disable post
        self.isURLValid = false
        
        // add new place to map view
        mapView.addAnnotation(place.placemark)
        mapView.selectAnnotation(place.placemark, animated: false)
        
        // focus on url textField
        textFieldURL.becomeFirstResponder()
    }
    
    //////////////////////////////////
    // MKMapViewDelegate
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
    
    //////////////////////////////////
    // Post action
    /////////////////////////////////
    
    @IBAction func postAction(sender: AnyObject) {
        
        // get current user information
        let currentUser = UDAppDelegate.sharedAppDelegate().currentUser
        
        // initial post information
        let postInfo = currentUser?.createPostInfoFor(place, URL: textFieldURL.text)
        println(postInfo)
        
        // post information using Parse API
        
        
        
        // completion with no error
        self.dismissViewControllerAnimated(true) {
            NSNotificationCenter.defaultCenter().postNotificationName(UDLocationDidPostNotification, object: postInfo)
        }
    }
}

