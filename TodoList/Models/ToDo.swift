//
//  File.swift
//  TodoList
//
//  Created by Usama Nasar on 16/07/2019.
//  Copyright © 2019 Usama Nasar. All rights reserved.
//

import Foundation
import Firebase

struct ToDo {
    
    let ref: DatabaseReference?
    let key: String
    let description: String
    let addedByUser: String
    var completed: Bool
    
    init(name: String, addedByUser: String, completed: Bool, key: String) {
        self.ref = nil
        self.key = key
        self.description = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let addedByUser = value["addedByUser"] as? String,
            let completed = value["completed"] as? Bool else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.description = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    func toAnyObject() -> Any {
        return [
            "name": description,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
}
