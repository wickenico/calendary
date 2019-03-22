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
    
    // add editbutton to the left side of navbar
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events"
        // load data and refresh table view in function refreshTableView()
        self.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        self.refreshTableView()
    }
    
    // tells the data source to return the number of rows in a given section of a table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (events?.count)!
    }
    
    // asks the data source for the title of the header of the specified section of the table view
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        
        // detecting today's date
        let startDateComponents = DateComponents()
        let todayDate = Calendar.current.date(byAdding: startDateComponents, to: Date())
        let startDate = dateFormatter.string(from: todayDate!)
        
        // detecting date in two weeks
        var endDateComponents = DateComponents()
        endDateComponents.day = 14
        let twoWeeksDate = Calendar.current.date(byAdding: endDateComponents, to: Date())
        let endDate = dateFormatter.string(from: twoWeeksDate!)
        
        // connecting string for headersection
        return "\(startDate) to \(endDate)"
    }
    
    // asks the data source for a cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        
        // write attributes in cell labels
        cell.textLabel?.text = events?[(indexPath as NSIndexPath).row].title
        cell.detailTextLabel?.text = dateFormatter.string(from: (events?[indexPath.row].startDate)!)
        cell.selectionStyle = .none
        return cell
    }
    
    // asks the data source to commit the insertion or deletion of a specified row in the receiver
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get title of the selected event in the row
            let altertEventTitle = events?[indexPath.row].title
            
            // creats alert dialog for delete
            let alertTitle = "Delete \(String(describing: altertEventTitle)) ?"
            let alertMessage = " Do you really want to delete this event?"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // if delete is confirmed remove table view row and the event
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action) -> Void in
                let deleteEvent = self.events?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                do {
                    // remove event in storage
                    try self.eventStore.remove(deleteEvent!, span: .thisEvent)
                } catch {
                    print("Could not delete Event")
                }
            })
            alert.addAction(deleteAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // tells the data source to move a row at a specific location in the table view to another location
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCalendar = self.events?[sourceIndexPath.row]
        events?.remove(at: sourceIndexPath.row)
        events?.insert(movedCalendar!, at: destinationIndexPath.row)
    }
    
    // loads the calendars and reloads the rows and sections of tableview
    @objc func refreshTableView() {
        self.loadEvents()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // return all events in the next fourteen days
    func loadEvents() {
        // create a date formatter instance to use for converting a string to a date
        let calendar = Calendar.current
        
        // create start and end date NSDate instances to build a predicate for which events to select
        var startDateComponents = DateComponents()
        startDateComponents.day = 0
        let startDate = calendar.date(byAdding: startDateComponents, to: Date())
        
        var endDateComponents = DateComponents()
        endDateComponents.day = 14
        let endDate = calendar.date(byAdding: endDateComponents, to: Date())
        
        // use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: nil)
        
        // use the configured NSPredicate to find and return events in the store that match
        self.events = eventStore.events(matching: eventsPredicate).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
    }
}
