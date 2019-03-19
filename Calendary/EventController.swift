//
//  EventController.swift
//  Calendary
//
//  Created by Nico Wickersheim on 19.03.19.
//  Copyright © 2019 Nico Wickersheim. All rights reserved.
//

import UIKit

class EventController: UITableViewController {
    
    let fruits = ["Apple", "Banana", "Raspberry"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fruits.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        let fruit = fruits[indexPath.row]
        
        cell.textLabel?.text = "Section \(indexPath.section), Row \(indexPath.row): \(fruit)"
        
        return cell
    }
    
    
    
}
