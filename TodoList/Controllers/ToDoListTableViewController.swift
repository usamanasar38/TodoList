//
//  ToDoListTableViewController.swift
//  TodoList
//
//  Created by Usama Nasar on 16/07/2019.
//  Copyright © 2019 Usama Nasar. All rights reserved.
//

import UIKit
import Firebase

class ToDoListTableViewController: UITableViewController {
    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var todos: [ToDo] = []
    var user: User!
    var userCountBarButtonItem: UIBarButtonItem!
    var ref = Database.database().reference(withPath: "todo")
    let usersRef = Database.database().reference(withPath: "online")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "User",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
        usersRef.observe(.value, with: { snapshot in
            if !snapshot.exists() {
                self.userCountBarButtonItem?.title = "User"
            }
        })
        
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems: [ToDo] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let todoTask = ToDo(snapshot: snapshot) {
                    if(todoTask.addedByUser == self.user.email){
                        newItems.append(todoTask)
                    }
                }
            }
            
            self.todos = newItems
            self.tableView.reloadData()
        })
    }
    
    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let todoTask = todos[indexPath.row]
        
        cell.textLabel?.text = todoTask.description
        cell.detailTextLabel?.text = todoTask.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: todoTask.completed)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //    if editingStyle == .delete {
    //      let todoTask = todos[indexPath.row]
    //      todoTask.ref?.removeValue()
    //    }
    //  }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let todoTask = self.todos[indexPath.row]
            todoTask.ref?.removeValue()
        }
        
        let update = UITableViewRowAction(style: .normal, title: "update") { (action, indexPath) in
            let todoTask = self.todos[indexPath.row]
            
            let alert = UIAlertController(title: "Edit Task Todo",
                                          message: "update description",
                                          preferredStyle: .alert)
            
            let update = UIAlertAction(title: "Update", style: .default) { _ in
                guard let textField = alert.textFields?.first,
                    let text = textField.text else { return }
                
                
                let updatedTodoTask = ToDo(name: text,
                                           addedByUser: todoTask.addedByUser,
                                           completed: todoTask.completed, key: todoTask.key)
                
                let todoTaskRef = self.ref.child(updatedTodoTask.key)
                
                todoTaskRef.updateChildValues(updatedTodoTask.toAnyObject() as! [AnyHashable : Any])
            }
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = todoTask.description
            })
            
            alert.addAction(update)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        update.backgroundColor = UIColor.lightGray
        
        return [delete, update]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let todoTask = todos[indexPath.row]
        let toggledCompletion = !todoTask.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        todoTask.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.textColor = .gray
        }
    }
    
    // MARK: Add Item
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Task Todo",
                                      message: "Add description",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            
            let todoTask = ToDo(name: text,
                                addedByUser: self.user.email,
                                completed: false, key: self.ref.childByAutoId().key!)
            
            let todoTaskRef = self.ref.child(todoTask.key)
            
            todoTaskRef.setValue(todoTask.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
