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
         
            // - Person to remove
            let personToRemove = self.people![indexPath.row]
            
            // - Remove the person
            self.context.delete(personToRemove)
            
            // - Save the data
            do {
                try self.context.save()
            } catch {
                print("Unable save after delet a person: \(error)")
            }
            
            // - Refetch the data
            self.fetchPeople()
        }
        
        item.image = UIImage(named: "deleteIcon")

        let swipeActions = UISwipeActionsConfiguration(actions: [item])
    
        return swipeActions

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPerson = self.people![indexPath.row]
        
        
        let alertController = UIAlertController(title: "Title", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = selectedPerson.name
        }
        let saveAction = UIAlertAction(title: "Update", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if let txt = textField.text {
                    print("Person Updated :: \(txt)")
                    
                    // - Update CoreData Person name
                    selectedPerson.name = txt
                    
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
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdent", for: indexPath)
        
        let person = self.people![indexPath.row]
        cell.textLabel?.text = person.name
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

