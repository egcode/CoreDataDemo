//
//  VC+Background.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/28/22.
//

import UIKit
import CoreData

extension VC {
    // MARK: - Print
    
    func printThread(operation:String) {
        if Thread.isMainThread {
            print("\(operation) on main thread")
        } else {
            print("\(operation) off main thread")
        }
    }
    
    // MARK: - CoreData Fetch - Background Thread
        
    func fetchPeopleBackgroundThread() {
        self.printThread(operation: "Fetch All Origin")
        
        do {
            
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            // Filter, only display people that has `blah` in their names
//            let blah = "blah"
//            let pred = NSPredicate(format: "name CONTAINS %@", blah)
//            request.predicate = pred
            
            // Sort, by name
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            self.people = try contextMain.fetch(request)
            
            // Update On Main Thread
            self.contextMain.perform {
                self.tableView.reloadData()
                self.printThread(operation: "Update TableView")
            }
        } catch {
            print("⛔️ERROR: \(error)")
        }
    }

    // MARK: - CoreData Add, Remove, Edit - Background Thread

    @objc func addPersonBackgroundThread() {
        let alertController = UIAlertController(title: "Title", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter name"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if let txt = textField.text {
                    print("\nPerson Added :: \(txt)")
                    self.printThread(operation: "Add Person Origin")

                    // Performs on Background Thread
                    self.persistentContainer.performBackgroundTask { [weak self] (context) in
                        
                        // - Create CoreData Person
                        let newPerson = Person(context: context)
                        newPerson.name = txt
                        newPerson.age = 10
                        newPerson.gender = "Male"
                        self?.printThread(operation: "New Person Created")

                        // - Save the Data
                        do {
                            try context.save()
                            self?.printThread(operation: "Save Context")
                        } catch {
                            print("⛔️Unable To save person \(error)")
                        }
                        
                        // - Re-Fetch the data
                        self?.fetchPeopleBackgroundThread()
                    }
                    
                } else {
                    print("No text to add")
                }
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.preferredAction = saveAction
        self.present(alertController, animated: true, completion: nil)
    }


    func removePersonBackgroundThread(indexPath: IndexPath) {
        
        // - Person to remove
        let personToRemove = self.people![indexPath.row]
        print("\nPerson Remove :: \(personToRemove.name)")
        self.printThread(operation: "Remove Person Origin")

        self.persistentContainer.performBackgroundTask { [weak self] (unusedContext) in
            if let s = self {

                // - Remove the person
                s.contextMain.delete(personToRemove) // USE GLOBAL CONTEXT
                s.printThread(operation: "Removed Person")

                // - Save the data
                do {
                    try s.contextMain.save()
                    self?.printThread(operation: "Save Context")

                } catch {
                    print("⛔️Unable save after delet a person: \(error)")
                }

                // - Refetch the data
                s.fetchPeopleBackgroundThread()
            }

        }
    }
    
    func editPersonBackgroundThread(indexPath: IndexPath) {
        let selectedPerson = self.people![indexPath.row]
        
        let alertController = UIAlertController(title: "Title", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = selectedPerson.name
        }
        let saveAction = UIAlertAction(title: "Update", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if let txt = textField.text {
                    print("\nPerson Updated :: \(txt)")
                    self.printThread(operation: "Edit Person Origin")

                    self.persistentContainer.performBackgroundTask { [weak self] (context) in
                        
                        // - Update CoreData Person name
                        selectedPerson.name = txt
                        self?.printThread(operation: "Update Person")

                        // - Save the Data
                        do {
                            try context.save()
                            self?.printThread(operation: "Save Context")

                        } catch {
                            print("⛔️Unable To save person \(error)")
                        }
                        
                        // - Re-Fetch the data
                        self?.fetchPeopleBackgroundThread()

                    }
                    
                    
                } else {
                    print("No text to add")
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.preferredAction = saveAction
        self.present(alertController, animated: true, completion: nil)
    }

    
    
    

}
