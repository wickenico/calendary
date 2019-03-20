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
    
    
    
    @IBAction func addNewItem(_ sender: UIButton) {
    }
    @IBAction func toggleEditingMode(_ sender: UIButton) {
        if isEditing {
            sender.setTitle("Edit", for: .normal)
            setEditing(false, animated: true)
        } else {
            sender.setTitle("Done", for: .normal)
            setEditing(true, animated: true)
        }
    }
    
    var eventStore = EKEventStore()
    var calendars:[EKCalendar]?
    
    let fruits = ["Apple", "Banana", "Raspberry"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Coming Events"
        
        self.checkAccess()
        self.loadCalendars()
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
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
            let calendarColor = calendars[indexPath.row].calendarIdentifier
            print("Calendar Name: \(calendarName)")
            cell.textLabel?.text = calendarName
            cell.detailTextLabel?.text = calendarColor
        } else {
            cell.textLabel?.text = "Unknown Calendar Name"
        }
        
        return cell
//
    }
    func refreshTableView() {
        self.tableView.reloadData()
    }
    
    func checkAccess(){
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            print("Authorized")
            self.fetchEvents()
        case .denied:
            print("Access denied")
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: {
                (granted: Bool, error: Error?) -> Void in
                if granted {
                    print("Access granted")
                } else {
                    print("Access denied")
                }
            })
            print("Not determinded")
        default:
            print("default")
        }}
    
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
    
    
}
