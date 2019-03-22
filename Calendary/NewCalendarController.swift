//
//  NewCalendarController.swift
//  Calendary
//
//  Created by Nico Wickersheim on 20.03.19.
//  Copyright © 2019 Nico Wickersheim. All rights reserved.
//

import UIKit
import EventKit

class NewCalendarController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var addCalendarField: UITextField!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Calendar"
        
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
    
    
    // save new calendar to storage
    @IBAction func saveNewCalendarButton(_ sender: UIBarButtonItem) {
        let eventStore = EKEventStore();
        
        // creates new EKCalender object
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        
        // write text from textField to new calendar object
        newCalendar.title = addCalendarField.text!
        
        // check and alert if textField is empty
        if addCalendarField.text?.count == 0 {
            let alert = UIAlertController(title: "Calendar name cannot be empty!", message: newCalendar.title, preferredStyle: .alert)
            let textAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(textAction)
            self.present(alert, animated: true, completion: nil)
            print("No calendar added")
        // textField is not empty
        } else {
            newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
            do {
                // save new calendar and alert
                try eventStore.saveCalendar(newCalendar, commit: true)
                let alert = UIAlertController(title: "Calendar is created", message: newCalendar.title, preferredStyle: .alert)
                let successAction = UIAlertAction(title: "Nice!", style: .default, handler: nil)
                alert.addAction(successAction)
                self.present(alert, animated: true, completion: nil)
            } catch {
                // error alert when save failed
                let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.navigationController?.popViewController(animated: true)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
