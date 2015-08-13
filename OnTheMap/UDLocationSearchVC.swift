//
//  UDLocationSearchVC.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//


import UIKit
import MapKit

let UDLocationPostDismissedNotification = "UDLocationPostDismissedNotification"

class UDLocationSearchVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBarView: UISearchBar!
    
    var geocoder: CLGeocoder? = nil
    var places: [MKMapItem]!
    
    //////////////////////////////////
    // MARK: Override methods
    /////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get current location and update textField to previous entered url
        let userID = UDAppDelegate.sharedAppDelegate().currentUser?.userID
        let moc = UDAppDelegate.sharedAppDelegate().managedObjectContext!
        if let obj = UDLocation.studentLocationForUniqueKey(userID!, inManagedObjectContext: moc) {
            searchBarView.text = obj.mapString
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // focus on search bar
        searchBarView.becomeFirstResponder()
    }
    
    //////////////////////////////////
    // MARK: Cancel action
    /////////////////////////////////
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true) {[weak self] in
            NSNotificationCenter.defaultCenter().postNotificationName(UDLocationPostDismissedNotification, object: self?.navigationController)
        }
    }
    
    //////////////////////////////////
    // MARK: UISearchBarDelegate
    /////////////////////////////////
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        
        startSearch(searchBar.text)
        
    }
    
    //////////////////////////////////
    // MARK: Search locations
    /////////////////////////////////
    
    func startSearch(searchString: String) {
        
        // clear previous search result
        places = nil
        tableView.reloadData()
        
        // cancel previous search if any
        geocoder?.cancelGeocode()
        
        // get user location
        let appDelegate = UIApplication.sharedApplication().delegate as? UDAppDelegate
        let userLocation = appDelegate?.userLocation
        
        // start search places with keyword
        geocoder = CLGeocoder.search(searchString) {[weak self] mapItems, error in
            if error != nil {
                let alert = UIAlertView(title: "Could not find any places", message: error?.localizedDescription,
                    delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                self?.places = mapItems
                self?.tableView.reloadData()
            }
        }
    }
    
    //////////////////////////////////
    // MARK: TableView DataSource
    /////////////////////////////////
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places == nil {
            return 0
        }
        return places.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        let place = places[0]
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.placemark.title
        
        return cell
    }
    
    //////////////////////////////////
    // MARK: TableView Delegate
    /////////////////////////////////
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the selected place
        let place = places[indexPath.row]
        
        // initailize postInfo vc
        let vc = storyboard?.instantiateViewControllerWithIdentifier("postInfoViewController") as? UDLocationPostVC
        
        // pass information
        vc?.place = place
        
        // push to vc
        navigationController?.pushViewController(vc!, animated: true)
    }
    
}
