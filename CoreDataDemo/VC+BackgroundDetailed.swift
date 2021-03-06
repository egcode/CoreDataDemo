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
                
        self.contextPrivate.parent = self.contextMain
        self.contextPrivate.perform { [weak self] in
            if let s = self {                
                do {
                    let request = Person.fetchRequest() as NSFetchRequest<Person>

                    // Filter, only display people that has `blah` in their names
        //            let blah = "blah"
        //            let pred = NSPredicate(format: "name CONTAINS %@", blah)
        //            request.predicate = pred

                    // Sort, by name
                    let sort = NSSortDescriptor(key: "name", ascending: true)
                    request.sortDescriptors = [sort]
                    s.people = try s.contextMain.fetch(request)
                    s.printThread(operation: "Fetch All contextMain.fetch")
                    
                    // Update On Main Thread
                    s.contextMain.perform {
                        s.tableView.reloadData()
                        s.printThread(operation: "Update TableView")
                    }
                } catch {
                    print("⛔️ERROR: \(error)")
                }
                
            } else {
                assertionFailure("🆘 Unable to get self")
            }
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
                    
                    // Performs on Background Thread
                    self.contextPrivate.parent = self.contextMain // - MUST
//                    self.contextPrivate.performAndWait { [weak self] in  // - Syncronous, will run in main thread
                    self.contextPrivate.perform { [weak self] in  // - Asyncrounous, will run in background thread
                        if let s = self {
                            // - Create CoreData Person
//                            let newPerson = Person(context: s.contextPrivate)
                            let newPerson = Person(context: s.contextMain)
                            newPerson.name = txt
                            newPerson.age = 10
                            newPerson.gender = "Male"
                            newPerson.idURL = newPerson.objectID.uriRepresentation()
                            print("✅ Created Object with ID: \(String(describing: newPerson.idURL?.absoluteString))")
                            self?.printThread(operation: "New Person Created")

                            // - Save the Data
                            do {
//                                // Save Private Context
//                                try s.contextPrivate.save()
//                                s.printThread(operation: "Save Private Context")

                                // Save Main Context
                                try s.contextMain.save()
                                s.printThread(operation: "Save Main Context")

                                // - Re-Fetch the data
                                s.fetchPeopleBackgroundThreadDetailed()

                            } catch {
                                fatalError("⛔️Unable To save person \(error)")
                            }
                        }
                    }
                    
//                    // Performs on Background Thread
//                    self.persistentContainer.performBackgroundTask { [weak self] (context) in
//
//                        // - Create CoreData Person
//                        let newPerson = Person(context: context)
//                        newPerson.name = txt
//                        newPerson.age = 10
//                        newPerson.gender = "Male"
//                        newPerson.idURL = newPerson.objectID.uriRepresentation()
//                        print("✅ Created Object with ID: \(String(describing: newPerson.idURL?.absoluteString))")
//                        self?.printThread(operation: "New Person Created")
//
//                        // - Save the Data
//                        do {
//                            try context.save()
//                            self?.printThread(operation: "Save Context")
//                        } catch {
//                            print("⛔️Unable To save person \(error)")
//                        }
//
//                        // - Re-Fetch the data
//                        self?.fetchPeopleBackgroundThread()
//                    }

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
        let personToRemove = self.people[indexPath.row]
        print("\nPerson Remove :: \(String(describing: personToRemove.name))")
        self.printThread(operation: "Remove Person Origin")
        
        // Performs on Background Thread
        self.contextPrivate.parent = self.contextMain // - MUST
        self.contextPrivate.automaticallyMergesChangesFromParent = true
        self.contextPrivate.perform { [weak self] in
            if let s = self {

                // - Remove the person
                s.contextMain.delete(personToRemove) // USE GLOBAL CONTEXT
                s.printThread(operation: "Removed Person Context Main")

                // - Save the data
                do {
                    try s.contextMain.save()
                    self?.printThread(operation: "Save Context Main")

                } catch {
                    print("⛔️Unable save after delet a person: \(error)")
                }

                // - Refetch the data
                s.fetchPeopleBackgroundThread()
            }
            
        }


        
        
//        // Performs on Background Thread
//        self.persistentContainer.performBackgroundTask { [weak self] (unusedContext) in
//            if let s = self {
//
//                // - Remove the person
//                s.contextMain.delete(personToRemove) // USE GLOBAL CONTEXT
//                s.printThread(operation: "Removed Person")
//
//                // - Save the data
//                do {
//                    try s.contextMain.save()
//                    self?.printThread(operation: "Save Context")
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
    }
    
    func editPersonBackgroundThreadDetailed(indexPath: IndexPath) {
        let selectedPerson = self.people[indexPath.row]
        
        let alertController = UIAlertController(title: "Title", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = selectedPerson.name
        }
        let saveAction = UIAlertAction(title: "Update", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if let txt = textField.text {
                    print("\nPerson Updated :: \(txt)")
                    self.printThread(operation: "Edit Person Origin")
                    
                    
                    self.contextPrivate.parent = self.contextMain
                    self.contextPrivate.perform { [weak self] in
                            
                        // - Update CoreData Person name
                        selectedPerson.name = txt
                        self?.printThread(operation: "Update Person")

                        // - Save the Data
                        do {
                            try self?.contextMain.save()
                            self?.printThread(operation: "Save Context Main")

                        } catch {
                            print("⛔️Unable To save person \(error)")
                        }

                        // - Re-Fetch the data
                        self?.fetchPeopleBackgroundThread()
                        
                    }
                    
                    
                    

//                    // Performs on Background Thread
//                    self.persistentContainer.performBackgroundTask { [weak self] (context) in
//
//                        // - Update CoreData Person name
//                        selectedPerson.name = txt
//                        self?.printThread(operation: "Update Person")
//
//                        // - Save the Data
//                        do {
//                            try self?.contextMain.save()
//                            self?.printThread(operation: "Save Context Main")
//
//                        } catch {
//                            print("⛔️Unable To save person \(error)")
//                        }
//
//                        // - Re-Fetch the data
//                        self?.fetchPeopleBackgroundThread()
//
//                    }
                    
                    
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
