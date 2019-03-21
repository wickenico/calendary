//
//  EventController.swift
//  Calendary
//
//  Created by Nico Wickersheim on 20.03.19.
//  Copyright © 2019 Nico Wickersheim. All rights reserved.
//

import UIKit
import EventKit

class EventController: UITableViewController {
    
    
    var calendar: EKCalendar!
    var events: [EKEvent]?
    let eventStore = EKEventStore()
    
    @IBAction func addEventButton(_ sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events"
//        self.loadEvents()
        self.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let startDateComponents = DateComponents()
        let todayDate = Calendar.current.date(byAdding: startDateComponents, to: Date())
        let startDate = dateFormatter.string(from: todayDate!)
        
        var endDateComponents = DateComponents()
        endDateComponents.day = 14
        let twoWeeksDate = Calendar.current.date(byAdding: endDateComponents, to: Date())
        let endDate = dateFormatter.string(from: twoWeeksDate!)
        
        return "\(startDate) to \(endDate)"
    }
    
    // move calendars in tableView
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCalendar = self.events?[sourceIndexPath.row]
        events?.remove(at: sourceIndexPath.row)
        events?.insert(movedCalendar!, at: destinationIndexPath.row)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkCalendarAuthorizationStatus()
    }
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Yo!! You got a access to use Calendar now go on and create/load all calendar list.
            //self.fetchEvents()
            self.refreshTableView()
            break
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to create another view which helps user to give us permission
            break
        }
    }
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    // Yo!! You got a access to use Calendar now go on and create/load all calendar list.
                    self.refreshTableView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    // We need to create another view which helps user to give us permission
                })
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let events = events {
            return events.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        
        cell.textLabel?.text = events?[(indexPath as NSIndexPath).row].title
        cell.detailTextLabel?.text = dateFormatter.string(from: (events?[indexPath.row].startDate)!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteEvent = self.events?.remove(at: indexPath.row)
            let alertTitle = "Delete \(String(describing: deleteEvent?.title)) ?"
            let alertMessage = " Do you really want to delete this event?"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action) -> Void in
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                do {
                    try self.eventStore.remove(deleteEvent!, span: .thisEvent)
                } catch {
                    print("shit")
                }
            })
            alert.addAction(deleteAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func loadEvents() {
        // Create a date formatter instance to use for converting a string to a date
        let calendar = Calendar.current
        
        // Create start and end date NSDate instances to build a predicate for which events to select
        var startDateComponents = DateComponents()
        startDateComponents.day = 0
        let startDate = calendar.date(byAdding: startDateComponents, to: Date())
        
        var endDateComponents = DateComponents()
        endDateComponents.day = 14
        let endDate = calendar.date(byAdding: endDateComponents, to: Date())
        
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: nil)
        
        // Use the configured NSPredicate to find and return events in the store that match
        self.events = eventStore.events(matching: eventsPredicate).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
    }
    
    @objc func refreshTableView() {
        self.loadEvents()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
}



