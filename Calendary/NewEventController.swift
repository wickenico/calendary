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
    
    // called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Event"
        
        // creates GestureRecognizer with function DismissKeyboard()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
   
    // closing keyboard when tap outside the textfield
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    // notifies the view controller that its view is about to be removed from a view hierarchy
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // is called when the system determines that the amount of available memory is low
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // asks the delegate if the text field should process the pressing of the return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // tells the delegate that editing began in the specified text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    // save new event to storage
    @IBAction func saveEventAction(_ sender: UIBarButtonItem) {
        let eventStore = EKEventStore()
        
        // creates new EKEVent object
        let newEvent = EKEvent(eventStore: eventStore)
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            
            // set attributes in new object for calendar "Calendar"
            if calendar.title == "Calendar" {
                newEvent.calendar = calendar
                newEvent.title = addEventField.text
                newEvent.startDate = self.startDatePicker.date
                newEvent.endDate = self.endDatePicker.date
                newEvent.isAllDay = true
                
                do {
                    // save new event and alert
                    try eventStore.save(newEvent, span: .thisEvent)
                    let alert = UIAlertController(title: "Event added!", message: newEvent.title, preferredStyle: .alert)
                    let successAction = UIAlertAction(title: "Nice!", style: .default, handler: nil)
                    alert.addAction(successAction)
                    self.present(alert, animated: true, completion: nil)
                    print("Calendar \(String(describing: newEvent.title)) added")
                } catch {
                    // error alert when save failed
                    let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    self.present(alert,animated: true,completion: nil)
                }
            }
        }
    }
}
