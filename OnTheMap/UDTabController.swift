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
import FBSDKLoginKit

class UDTabController: UITabBarController, UIAlertViewDelegate {
    
    var locationManager: CLLocationManager!
    var moc: NSManagedObjectContext!
    
    // alertView's tag
    let kAlertTagSignOut = 0
    let kAlertTagUpdateLocation = 1
    
    @IBOutlet weak var barItemSignOut: UIBarButtonItem!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var activityCount = UDActivityCount()
    var isLoading: Bool = false {
        didSet {
            if activityCount.startOrStopActivity(isLoading) {
                return
            }
            
            barItemSignOut.enabled = !isLoading
            btnAdd.alpha = CGFloat(!isLoading)
            btnRefresh.alpha = CGFloat(!isLoading)
            if isLoading {
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
        
        // get the moc
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        moc = appDelegate.managedObjectContext!
        
        // reset ui state
        self.isLoading = false
    }
    
    //////////////////////////////////
    // MARK: Actions
    /////////////////////////////////
    
    @IBAction func signOutAction(sender: AnyObject) {
        
        let alert = UIAlertView(title: "SignOut", message: "Are you sure sign out?",
            delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.tag = kAlertTagSignOut
        alert.show()
        
        
    }
    
    @IBAction func addLocationAction(sender: AnyObject) {
        let userID = UDAppDelegate.sharedAppDelegate().currentUser?.userID
        if let obj = UDLocation.studentLocationForUniqueKey(userID!, inManagedObjectContext: moc) {
            let alert = UIAlertView(title: "Your location posted", message: "Are you sure overwrite current location?",
                delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            alert.tag = kAlertTagUpdateLocation
            alert.show()
        }
        else {
            presentPostingLocationVC()
        }
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        
        // hide buttons and show spinner
        self.isLoading = true
        
        // initial fetch request
        let fetchRequest = NSFetchRequest(entityName: UDLocation.kUDLocation)
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: UDLocation.JSONKeys.createdAt, ascending: true)]
        
        // search for all location object
        let results = moc.executeFetchRequest(fetchRequest, error: nil) as! [UDLocation]
        
        // delete all existing locations
        for loc in results {
            moc.deleteObject(loc)
        }
        
        // populate locations
        let parameters: [String: AnyObject] = [UDParseClient.ParametersKey.Order: "-\(UDParseClient.ParametersValue.updatedAt)"]
        
        UDParseClient.recurQueryStudentLocations(parameters) {[weak self] result, finished, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    let alert = UIAlertView(title: "Communications error", message: error?.localizedDescription,
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    self?.isLoading = false
                }
                else if let context = self?.moc {
                    if let results = result as? [[String: AnyObject]] {
                        UDLocation.locationsFromResults(results, moc: context)
                    }
                }
                
                // reset ui state
                if finished {
                    self?.isLoading = false
                }
            }
            
        }
    }
    
    //////////////////////////////////
    // MARK: UIAlertViewDelegate
    /////////////////////////////////
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        // ok button tapped, cancel button's index value is 0
        if buttonIndex != 0 {
            if alertView.tag == kAlertTagUpdateLocation {
                presentPostingLocationVC()
            }
            else if alertView.tag == kAlertTagSignOut {
                signOut()
            }
            else {
                assert(false, "Unknown alert view")
            }
        }
    }
    
    //////////////////////////////////
    // MARK: Internal methods
    /////////////////////////////////
    
    func presentPostingLocationVC() {
        // hide buttons and show spinner
        self.isLoading = true
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("LocationPostNavigation") as! UIViewController
        
        // subcribe to posting location vc dismiss event
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationPostDismissed:", name: UDLocationPostDismissedNotification, object: vc)
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func locationPostDismissed(notitication: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UDLocationPostDismissedNotification, object: notitication.object)
        
        // reset ui state
        self.isLoading = false
    }
    
    func signOut() {
        
        // disable signout button and show spinner
        self.isLoading = true
        
        UDClient.logout() { [unowned self] result, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    FBSDKAccessToken.setCurrentAccessToken(nil)
                    FBSDKProfile.setCurrentProfile(nil)
                    self.dismissViewControllerAnimated(true, completion:nil)
                }
                else {
                    let alert = UIAlertView(title: "Communications error", message: error?.localizedDescription,
                        delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
                
                // reset ui state
                self.isLoading = false
            }
        }
    }
}
