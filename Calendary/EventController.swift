//
//  EventController.swift
//  Calendary
//
//  Created by Nico Wickersheim on 19.03.19.
//  Copyright © 2019 Nico Wickersheim. All rights reserved.
//

import UIKit
import EventKit

class EventController: UITableViewController {
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let lastRow = tableView.numberOfRows(inSection: 0)
        let indexPath = IndexPath(row: lastRow, section: 0)
        
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    var eventStore = EKEventStore()
    var calendars:[EKCalendar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Coming Events"
        
        //self.checkAccess()
        self.loadCalendars()
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
            self.fetchEvents()
            self.loadCalendars()
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
                    self.loadCalendars()
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
        if let calendars = self.calendars {
            return calendars.count
        }
        return 0
    }
    
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        if let calendars = self.calendars {
            let calendarName = calendars[indexPath.row].title
            let calenderIdentifier = calendars[indexPath.row].calendarIdentifier
//            let calenderType = String(describing: calendars[indexPath.row].type)
//            let calenderSource = String(describing: calendars[indexPath.row].source)
            let calendarColor = calendars[indexPath.row].cgColor
            
            print("Calendar Name: \(calendarName)")
            cell.textLabel?.text = calendarName
            cell.detailTextLabel?.text = calenderIdentifier
//            cell.backgroundColor = UIColor.init(cgColor: calendarColor!)
            cell.detailTextLabel?.text = UIColor.init(cgColor: calendarColor!)
        } else {
            cell.textLabel?.text = "Unknown Calendar Name"
        }
        
        return cell
        //
    }
    @objc func refreshTableView() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func fetchEvents(){
        let now = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents.init()
        dateComponents.day = 7
        let futureDate = calendar.date(byAdding: dateComponents, to: now) // 1
        
        let eventsPredicate = self.eventStore.predicateForEvents(withStart: now, end: futureDate!, calendars: nil) // 2
        
        let events = self.eventStore.events(matching: eventsPredicate)
        
        for event in events{
            
            print("\(String(describing: event.title))")
            
        }
    }
    
    func loadCalendars() {
        self.calendars = eventStore.calendars(for: EKEntityType.event)
    }
    
    // delete calendar temporary from tableView
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteCalendar = self.calendars?.remove(at: indexPath.row)
            
            let alertTitle = "Delete \(deleteCalendar!.title) ?"
            let alertMessage = " Do you really want to delete this calendar?"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action) -> Void in
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                do {
                    try self.eventStore.removeCalendar(deleteCalendar!, commit: true)
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
        let movedCalendar = self.calendars?[sourceIndexPath.row]
        calendars?.remove(at: sourceIndexPath.row)
        calendars?.insert(movedCalendar!, at: destinationIndexPath.row)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
}
