//
//  SecondViewController.swift
//  OnTheMap
//
//  Created by Tu Tong on 8/4/15.
//  Copyright (c) 2015 Tu Tong. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var moc: NSManagedObjectContext!
    var frController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get the moc
        let appDelegate = UIApplication.sharedApplication().delegate as! UDAppDelegate
        moc = appDelegate.managedObjectContext!
        
        // initializes fetch controller
        setupFetchedResultsController()
        
    }
    
    //////////////////////////////////
    // NSFetchedResultsControllerDelegate
    /////////////////////////////////
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex),
                withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            println(sectionInfo)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if let loc = anObject as? UDLocation {
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath as! AnyObject],
                    withRowAnimation: UITableViewRowAnimation.Fade)
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!)!
                configCell(cell, locationObject: anObject as! UDLocation)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath as! AnyObject],
                    withRowAnimation: UITableViewRowAnimation.Fade)
            default:
                println(loc)
            }
        }
    }
    
    //////////////////////////////////
    // Table View Data source
    /////////////////////////////////
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = frController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frController.sections {
            let currentSection = sections[section] as! NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    func configCell(cell: UITableViewCell, locationObject: UDLocation) {
        cell.textLabel?.text = locationObject.annoTitle()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath) as! UITableViewCell
        
        let loc = frController.objectAtIndexPath(indexPath) as? UDLocation
        configCell(cell, locationObject: loc!)
        
        return cell
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
}

