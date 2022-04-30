//
//  VC+TableView.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/27/22.
//

import UIKit

extension VC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = UIContextualAction(style: .destructive, title: "RemovePers") {  (contextualAction, view, boolValue) in
            
            switch self.performOn {
            case .main:
                self.removePerson(indexPath: indexPath)
                break
            case .background:
                self.removePersonBackgroundThread(indexPath: indexPath)
                break
            case .backgroundDetailed:
                self.removePersonBackgroundThreadDetailed(indexPath: indexPath)
                break
            }
        }
        
        item.image = UIImage(named: "deleteIcon")
        let swipeActions = UISwipeActionsConfiguration(actions: [item])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch self.performOn {
        case .main:
            self.editPerson(indexPath: indexPath)
            break
        case .background:
            self.editPersonBackgroundThread(indexPath: indexPath)
            break
        case .backgroundDetailed:
            self.editPersonBackgroundThreadDetailed(indexPath: indexPath)
            break
        }
    }

    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdent", for: indexPath)
        
        let person = self.people[indexPath.row]
        cell.textLabel?.text = person.name
        return cell
    }

}

