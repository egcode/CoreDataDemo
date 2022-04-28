//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/27/22.
//

import UIKit




class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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

    // MARK: - CoreData Fetch all
    
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


    
    // MARK: - Table view delegate

    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.people!.count
//        return 3

    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdent", for: indexPath)
        
        let person = self.people![indexPath.row]
        cell.textLabel?.text = person.name
//        cell.textLabel?.text = "aa"

        // Configure the cell...

        return cell
    }

    
    /*
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    

}

