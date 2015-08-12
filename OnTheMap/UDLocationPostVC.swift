//
//  UDLocationPostVC.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import MapKit

class UDLocationPostVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    var place: MKMapItem!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var barItemPost: UIBarButtonItem!
    @IBOutlet weak var lblWarning: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var isURLValid: Bool = false {
        didSet {
            barItemPost.enabled = isURLValid
            lblWarning.hidden = isURLValid
        }
    }
    
    var activityCount = UDActivityCount()
    var isPosting: Bool = false {
        didSet {
            // should stop spinner ?
            if activityCount.startOrStopActivity(isPosting) {
                return
            }
            
            textFieldURL.alpha = CGFloat(!isPosting)
            barItemPost.enabled = !isPosting
            lblWarning.alpha = CGFloat(!isPosting)
            if isPosting {
                spinner.startAnimating()
            }
            else {
                spinner.stopAnimating()
            }
        }
    }
    
    //////////////////////////////////
    // MARK: Override methods
    /////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ui default state
        self.isPosting = false
        
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
    
    func mapViewWillStartLoadingMap(mapView: MKMapView!) {
        self.isPosting = true
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView!, withError error: NSError!) {
        self.isPosting = false
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        self.isPosting = false
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
        
        // get current user id
        let userID = currentUser?.userID
        
        // show spinner and hide other controls
        self.isPosting = true
        
        UDParseClient.postOrUpdateStudentLocation(userID!, postBody: postInfo!) {[weak self] result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    let alert = UIAlertView(title: "Communications error", message: error?.localizedDescription,
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    self?.isPosting = false
                }
                else { // post completed with no error
                    
                    // dismiss view controller
                    self?.dismissViewControllerAnimated(true) {
                        
                        // create or update current location
                        let loc = UDLocation.createOrUpdateStudentLocation(userID!,
                            decodeDict: result as! [String: AnyObject],
                            inManagedObjectContext: moc!)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(UDLocationPostDismissedNotification, object: self?.navigationController)
                        self?.isPosting = false
                    }
                }
            }
        }
    }
}

