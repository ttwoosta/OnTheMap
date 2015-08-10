//
//  UDLocationSearchVC.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/9/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//


import UIKit
import MapKit

class UDLocationSearchVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBarView: UISearchBar!
    
    var localSearch: MKLocalSearch!
    var places: [MKMapItem]!
    
    //////////////////////////////////
    // Override methods
    /////////////////////////////////
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // focus on search bar
        searchBarView.becomeFirstResponder()
    }
    
    //////////////////////////////////
    // Cancel action
    /////////////////////////////////
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
    //////////////////////////////////
    // UISearchBarDelegate
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
        
        // check to see if Location Services is enabled, there are two state possibilities:
        // 1) disabled for entire device, 
        // 2) disabled just for this app
        var causeStr: String!
        
        if CLLocationManager.locationServicesEnabled() == false {
            causeStr = "device"
        }
        else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            causeStr = "app"
        }
        else {
            startSearch(searchBar.text)
        }
        
        if causeStr != nil {
            let alertStr = "You currently have location services disabled for this \(causeStr). Please refer to \"Settings\" app to turn on Location Services."
            let alert = UIAlertView(title: "Location service is disabled", message: alertStr,
                delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    //////////////////////////////////
    // Search locations
    /////////////////////////////////
    
    func startSearch(searchString: String) {
        
        // cancel previous search if any
        if localSearch != nil && localSearch.searching {
            localSearch.cancel()
        }
        
        // get user location
        let appDelegate = UIApplication.sharedApplication().delegate as? UDAppDelegate
        let userLocation = appDelegate?.userLocation
        
        // start search places with keyword and user location
        localSearch = MKLocalSearch.search(searchString, userLocation: userLocation) { mapItems, error in
            if error != nil {
                let alert = UIAlertView(title: "Could not find any places", message: error?.localizedDescription,
                    delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            else {
                self.places = mapItems
                self.tableView.reloadData()
            }
        
        }
    }
    
    
    //////////////////////////////////
    // TableView DataSource
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
    // TableView Delegate
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
