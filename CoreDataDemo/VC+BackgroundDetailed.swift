//
//  VC+BackgroundDetailed.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/28/22.
//

import UIKit
import CoreData

extension VC {
    
    // MARK: - CoreData Fetch - Background Thread
        
    func fetchPeopleBackgroundThreadDetailed() {
        self.printThread(operation: "Fetch All Origin")
        
//        self.contextMain.performAndWait {
//            do {
//
//                let request = Person.fetchRequest() as NSFetchRequest<Person>
//
////                // Filter, only display people that has `blah` in their names
////                let blah = "blah"
////                let pred = NSPredicate(format: "name CONTAINS %@", blah)
////                request.predicate = pred
//
//                // Sort, by name
//                let sort = NSSortDescriptor(key: "name", ascending: true)
//                request.sortDescriptors = [sort]
//                self.people = try contextMain.fetch(request)
//                self.printThread(operation: "Fetch All contextMain.fetch")
//
//                self.tableView.reloadData()
//                self.printThread(operation: "Update TableView")
//
//            } catch {
//                print("⛔️ERROR: \(error)")
//            }
//        }
        
        
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

    @objc func addPersonBackgroundThreadDetailed() {
        let alertController = UIAlertController(title: "Title", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter name"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if let txt = textField.text {
                    print("\nPerson Added :: \(txt)")
                    self.printThread(operation: "Add Person Origin")
                    
//                    // Performs on Background Thread
//                    self.contextPrivate.parent = self.contextMain // - MUST
//                    self.contextPrivate.perform { [weak self] in
//                        if let s = self {
//                            // - Create CoreData Person
//                            let newPerson = Person(context: s.contextPrivate)
//                            newPerson.name = txt
//                            newPerson.age = 10
//                            newPerson.gender = "Male"
//                            self?.printThread(operation: "New Person Created")
//
//                            // - Save the Data
//                            do {
//                                // Save Private Context
//                                try s.contextPrivate.save()
//                                s.printThread(operation: "Save Private Context")
//
//
//                                s.contextMain.performAndWait {
//                                    do {
//                                        // Save Main Context
//                                        try s.contextMain.save()
//                                        s.printThread(operation: "Save Main Context")
//
//                                        // - Re-Fetch the data
//                                        s.fetchPeopleBackgroundThreadDetailed()
//                                    } catch {
//                                        fatalError("⛔️ failure to save context: \(error)")
//                                    }
//                                }
//                            } catch {
//                                fatalError("⛔️Unable To save person \(error)")
//                            }
//                        }
//                    }
                    
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


    func removePersonBackgroundThreadDetailed(indexPath: IndexPath) {
        
        // - Person to remove
        let personToRemove = self.people![indexPath.row]
        print("\nPerson Remove :: \(personToRemove.name)")
        self.printThread(operation: "Remove Person Origin")
        
        // Performs on Background Thread
//        self.contextPrivate.parent = self.contextMain // - MUST
//        self.contextPrivate.perform {[weak self] in
//            if let s = self {
//
//                // - Remove the person
//                s.contextPrivate.delete(personToRemove) // USE GLOBAL CONTEXT
//                s.printThread(operation: "Removed Person Private")
//
//                // - Save the data
//                do {
//                    // Save Main Context
//                    try s.contextPrivate.save()
//                    self?.printThread(operation: "Save Context Private")
//
//
//                    s.contextMain.performAndWait {
//                        do {
//                            // Save Main Context
//                            try s.contextMain.save()
//                            s.printThread(operation: "Save Main Context")
//
//                            // - Re-Fetch the data
//                            s.fetchPeopleBackgroundThreadDetailed()
//                        } catch {
//                            fatalError("⛔️ failure to save context: \(error)")
//                        }
//                    }
//
//
//                } catch {
//                    print("⛔️Unable save after delet a person: \(error)")
//                }
//
//                // - Refetch the data
//                s.fetchPeopleBackgroundThread()
//            }
//
//        }
        
        // Performs on Background Thread
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
    
    func editPersonBackgroundThreadDetailed(indexPath: IndexPath) {
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

                    
                    // Performs on Background Thread
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
