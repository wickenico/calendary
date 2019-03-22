//
//  NewEventController.swift
//  Calendary
//
//  Created by Nico Wickersheim on 21.03.19.
//  Copyright © 2019 Nico Wickersheim. All rights reserved.
//

import UIKit
import EventKit

class NewEventController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var addEventField: UITextField!
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func startDatePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
    }
    
    @IBAction func endDatePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Event"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard(){
        //Causes the view to resign from the status of first responder.
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    @IBAction func saveEventAction(_ sender: UIBarButtonItem) {
        let eventStore = EKEventStore()
        let newEvent = EKEvent(eventStore: eventStore)
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            
            if calendar.title == "Calendar" {
                newEvent.calendar = calendar
                newEvent.title = addEventField.text
                newEvent.startDate = self.startDatePicker.date
                newEvent.endDate = self.endDatePicker.date
                newEvent.isAllDay = true
                
                do {
                    try eventStore.save(newEvent, span: .thisEvent)
                    let alert = UIAlertController(title: "Event added!", message: newEvent.title, preferredStyle: .alert)
                    let successAction = UIAlertAction(title: "Nice!", style: .default, handler: nil)
                    alert.addAction(successAction)
                    self.present(alert, animated: true, completion: nil)
                    print("Calendar \(String(describing: newEvent.title)) added")
                } catch {
                    let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    self.present(alert,animated: true,completion: nil)
                }
            }
        }
    }
}
