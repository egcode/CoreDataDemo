//
//  ViewController+TableView.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/27/22.
//

import UIKit

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people!.count
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(style: .destructive, title: "RemovePers") {  (contextualAction, view, boolValue) in
            if self.performOnBackground {
                self.removePersonBackgroundThread(indexPath: indexPath)
            } else {
                self.removePerson(indexPath: indexPath)
            }
        }
        
        item.image = UIImage(named: "deleteIcon")
        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.performOnBackground {
            self.editPersonBackgroundThread(indexPath: indexPath)
        } else {
            self.editPerson(indexPath: indexPath)
        }
    }

    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdent", for: indexPath)
        
        let person = self.people![indexPath.row]
        cell.textLabel?.text = person.name
        return cell
    }

}

