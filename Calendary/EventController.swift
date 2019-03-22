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
    
    let eventStore = EKEventStore()
    var calendar: EKCalendar!
    var events: [EKEvent]?
    
    @IBAction func addEventButton(_ sender: UIBarButtonItem) {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events"
        self.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshTableView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (events?.count)!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        
        let startDateComponents = DateComponents()
        let todayDate = Calendar.current.date(byAdding: startDateComponents, to: Date())
        let startDate = dateFormatter.string(from: todayDate!)
        
        var endDateComponents = DateComponents()
        endDateComponents.day = 14
        let twoWeeksDate = Calendar.current.date(byAdding: endDateComponents, to: Date())
        let endDate = dateFormatter.string(from: twoWeeksDate!)
        
        return "\(startDate) to \(endDate)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        
        cell.textLabel?.text = events?[(indexPath as NSIndexPath).row].title
        cell.detailTextLabel?.text = dateFormatter.string(from: (events?[indexPath.row].startDate)!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let altertEventTitle = events?[indexPath.row].title
            
            let alertTitle = "Delete \(String(describing: altertEventTitle)) ?"
            let alertMessage = " Do you really want to delete this event?"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action) -> Void in
                let deleteEvent = self.events?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                do {
                    try self.eventStore.remove(deleteEvent!, span: .thisEvent)
                } catch {
                    print("Could not delete Event")
                }
            })
            alert.addAction(deleteAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // move calendars in tableView
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCalendar = self.events?[sourceIndexPath.row]
        events?.remove(at: sourceIndexPath.row)
        events?.insert(movedCalendar!, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let id = events![indexPath.row]
        //        var identifier = id.calendarItemIdentifier
        //        let calendarItem = eventStore.calendarItem(withIdentifier: identifier)
        //        let url = calendarItem!.url
        //        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    @objc func refreshTableView() {
        self.loadEvents()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
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
}
