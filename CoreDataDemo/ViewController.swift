//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/27/22.
//

import UIKit




class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people:[Person]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
//        //Fake People
//        let p1 = Person()
//        p1.name = "NameOne"
//        self.people.append(p1)
        
        // Add NavigationBar button
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
        self.navigationItem.rightBarButtonItem = barButton

        
        self.fetchPeople()
    }

    // MARK: - CoreData Fetch
    
    func fetchPeople() {
        do {
            self.people = try context.fetch(Person.fetchRequest())
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
                    // Create CoreData Person
                    let newPerson = Person(context: self.context)
                    newPerson.name = txt
                    newPerson.age = 10
                    newPerson.gender = "Male"
                    
                    // Save the Data
                    do {
                        try self.context.save()
                    } catch {
                        print("Unable To save person \(error)")
                    }
                    
                    // Re-Fetch the data
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

