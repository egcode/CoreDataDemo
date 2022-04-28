//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/27/22.
//

import UIKit
import CoreData




class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people:[Person]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Add NavigationBar button
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        self.navigationItem.rightBarButtonItem = barButton

        
        self.fetchPeople()
    }

    // MARK: - CoreData Fetch
    
    func fetchPeople() {
        do {
            
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            // Filter, only display people that has `blah` in their names
//            let blah = "blah"
//            let pred = NSPredicate(format: "name CONTAINS %@", blah)
//            request.predicate = pred
            
            // Sort, by name
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.people = try context.fetch(request)
            DispatchQueue.main.async { self.tableView.reloadData() }
        } catch {
            print("ERROR: \(error)")
        }
    }


    // MARK: - CoreData Add

    @objc func addPerson() {
        let alertController = UIAlertController(title: "Title", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter name"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if let txt = textField.text {
                    print("Person Added :: \(txt)")
                    
                    // - Create CoreData Person
                    let newPerson = Person(context: self.context)
                    newPerson.name = txt
                    newPerson.age = 10
                    newPerson.gender = "Male"
                    
                    // - Save the Data
                    do {
                        try self.context.save()
                    } catch {
                        print("Unable To save person \(error)")
                    }
                    
                    // - Re-Fetch the data
                    self.fetchPeople()
                    
                    
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

