//
//  EventController.swift
//  Calendary
//
//  Created by Nico Wickersheim on 19.03.19.
//  Copyright © 2019 Nico Wickersheim. All rights reserved.
//

import UIKit
import EventKit

class CalendarController: UITableViewController {
    
    var events: [EKEvent]?
    var eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    
    // add editbutton to the left side of navbar
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendars"
        // load data and refresh table view in function refreshTableView()
        self.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        // check if access to calendar is granted
        checkCalendarAuthorizationStatus()
    }
    
    // tells the data source to return the number of rows in a given section of a table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    // asks the data source for a cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath)
        
        // detecting calendar attributes
        let calendarName = calendars[indexPath.row].title
        let calenderIdentifier = calendars[indexPath.row].calendarIdentifier
        let calendarColor = calendars[indexPath.row].cgColor
        
        // write attributes in cell labels
        cell.textLabel?.text = calendarName
        cell.textLabel?.textColor = UIColor.init(cgColor: calendarColor!)
        cell.detailTextLabel?.text = calenderIdentifier
        return cell
    }
    
    // asks the data source to commit the insertion or deletion of a specified row in the receiver
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // get title of the selected calendar in the row
            let alertCalendarTitle = calendars[indexPath.row].title
            
            // creats alert dialog for delete
            let alertTitle = "Delete \(alertCalendarTitle)?"
            let alertMessage = " Do you really want to delete this calendar?"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            // if delete is confirmed remove table view row and the calendar
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action) -> Void in
                let deleteCalendar = self.calendars.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                do {
                    // remove calendar in storage
                    try self.eventStore.removeCalendar(deleteCalendar, commit: true)
                } catch {
                    print("Could not delete Calendar")
                }
            })
            alert.addAction(deleteAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // tells the data source to move a row at a specific location in the table view to another location
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCalendar = self.calendars[sourceIndexPath.row]
        calendars.remove(at: sourceIndexPath.row)
        calendars.insert(movedCalendar, at: destinationIndexPath.row)
    }
    
    // tells the delegate that the specified row is now selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let calendar = Calendar.current
        print("Current \(calendar)")
        
        // find the calendar and get title of the selected row
        let rowCalendar = calendars[indexPath.row]
        let calendarTitle = rowCalendar.title
        print(calendarTitle)
        
        // fill today's date in startDate
        var startDateComponents = DateComponents()
        startDateComponents.day = 0
        let startDate = calendar.date(byAdding: startDateComponents, to: Date())
        
        // fill date in week in endDate
        var endDateComponents = DateComponents()
        endDateComponents.day = 7
        let endDate = calendar.date(byAdding: endDateComponents, to: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        
        // definition of logical conditions used to constrain a search either for a fetch or for in-memory filtering
        var predicate: NSPredicate? = nil
        if let startDate = startDate, let endDate = endDate {
            // find events in the store in the given range
            predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [rowCalendar])
        }
        
        var events: [EKEvent]? = nil
        if let aPredicate = predicate {
            // returns all events that match the given predicate
            events = eventStore.events(matching: aPredicate)
            
            for event in events! {
                print(event.title)
                
                // remove the word "optional" from event.title
                let eventTitleWithoutOptional = event.title.replacingOccurrences(of: "Optional", with: "")
                
                // create alert with next event of the selected calendar
                let alertDate = dateFormatter.string(from: event.startDate)
                let alertTitle = "Next Event in \(calendarTitle):"
                let alertMessage = " The next Event is \(eventTitleWithoutOptional) on \(alertDate)"
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Thanks", style: .default, handler: nil)
                alert.addAction(defaultAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // loads the calendars and reloads the rows and sections of tableview
    @objc func refreshTableView() {
        self.loadCalendars()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // returns all calendars from storage
    func loadCalendars() {
        self.calendars = eventStore.calendars(for: EKEntityType.event)
    }
    
    // check the status of calendar access
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // this happens on first-run of app
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // got a access to use Calendar and load the data in tableview
            self.refreshTableView()
            break
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // need to create another view which helps user to give us permission
            break
        }
    }
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    // got a access to use Calendar and load the data in tableview
                    self.refreshTableView()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    // need to create another view which helps user to give us permission
                })
            }
        })
    }
}
