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
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let lastRow = tableView.numberOfRows(inSection: 0)
        let indexPath = IndexPath(row: lastRow, section: 0)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    var events: [EKEvent]?
    var eventStore = EKEventStore()
    var calendars = [EKCalendar]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calendars"
        
        self.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
        
            return calendars.count
        
    
    }
    
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath)
        
   
            let calendarName = calendars[indexPath.row].title
            let calenderIdentifier = calendars[indexPath.row].calendarIdentifier
//            let calenderType = String(describing: calendars[indexPath.row].type)
//            let calenderSource = String(describing: calendars[indexPath.row].source)
            let calendarColor = calendars[indexPath.row].cgColor
            
//            print("Calendar Name: \(calendarName)")
            cell.textLabel?.text = calendarName
            cell.textLabel?.textColor = UIColor.init(cgColor: calendarColor!)
            cell.detailTextLabel?.text = calenderIdentifier
//            cell.backgroundColor = UIColor.init(cgColor: calendarColor!)

        
        return cell
        //
    }
    @objc func refreshTableView() {
        self.loadCalendars()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func loadCalendars() {
        self.calendars = eventStore.calendars(for: EKEntityType.event)
    }
    
    // delete calendar temporary from tableView
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteCalendar = self.calendars.remove(at: indexPath.row)
            
            let alertTitle = "Delete \(deleteCalendar.title) ?"
            let alertMessage = " Do you really want to delete this calendar?"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action) -> Void in
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                do {
                    try self.eventStore.removeCalendar(deleteCalendar, commit: true)
                } catch {
                    print("shit")
                }
            })
            alert.addAction(deleteAction)
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    // move calendars in tableView
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCalendar = self.calendars[sourceIndexPath.row]
        calendars.remove(at: sourceIndexPath.row)
        calendars.insert(movedCalendar, at: destinationIndexPath.row)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let calendarTitle = calendars![indexPath.row].title
//        print(calendarTitle)
        let calendar = Calendar.current
        print("Current \(calendar)")
        
        let rowCalendar = calendars[indexPath.row]
        let calendarTitle = rowCalendar.title
        print(calendarTitle)
        
        var startDateComponents = DateComponents()
        startDateComponents.day = 0
        let startDate = calendar.date(byAdding: startDateComponents, to: Date())
        
        var endDateComponents = DateComponents()
        endDateComponents.day = 7
        let endDate = calendar.date(byAdding: endDateComponents, to: Date())
        
        var predicate: NSPredicate? = nil
        if let startDate = startDate, let endDate = endDate {
            predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [rowCalendar])
        }
        
        var events: [EKEvent]? = nil
        if let aPredicate = predicate {
            events = eventStore.events(matching: aPredicate)
            
            for event in events! {
                print(event.title)
                let alertTitle = "Next Events in \(calendarTitle)"
                let alertMessage = " The next Event is \(event.title) "
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
            
            
        }
        
        
    }
}
