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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Calendar"
        addCalendarField.text = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCalendarField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        
    }
    
    @IBAction func saveNewCalendarButton(_ sender: UIBarButtonItem) {
        let eventStore = EKEventStore();
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = addCalendarField.text!
        if addCalendarField.text?.count == 0 {
            let alert = UIAlertController(title: "Calendar Name cannot be empty!", message: newCalendar.title, preferredStyle: .alert)
            let textAction = UIAlertAction(title: "Ok!", style: .default, handler: nil)
            alert.addAction(textAction)
            self.present(alert, animated: true, completion: nil)
            print("No calendar added")
        } else {
            newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            let alert = UIAlertController(title: "Calendar added!", message: newCalendar.title, preferredStyle: .alert)
            let successAction = UIAlertAction(title: "Nice!", style: .default, handler: nil)
            alert.addAction(successAction)
            self.present(alert, animated: true, completion: nil)
            print("Calendar \(newCalendar.title) added")
            addCalendarField.text = ""
        } catch {
            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.navigationController?.popViewController(animated: true)
            self.present(alert, animated: true, completion: nil)
        }
        }
    }
    
}
