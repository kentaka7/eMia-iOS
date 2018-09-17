//
//  FirebaseItem.swift
//  eMia
//
//  Created by Sergey Krotkih on 29/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

class FirebaseItem {

   func primaryKey() -> String {
      assert(false, "Override this func!")
      return ""
   }

   func setPrimaryKey(_ key: String) {
      assert(false, "Override this func!")
   }

   func toDictionary() -> [String: Any] {
      assert(false, "Override this func!")
      return [:]
   }
   
   var tableName: String {
      assert(false, "Override this func!")
      return ""
   }
}

//

extension FirebaseItem {

   func synchronize(completion: @escaping (Bool) -> Void) {
      if self.primaryKey().isEmpty {
         save(completion: completion)
      } else {
         update(completion: completion)
      }
   }
   
   // Update exists data in the Firebase database
   private func update(completion: @escaping (Bool) -> Void) {
      let childUpdates = ["/\(self.tableName)/\(self.primaryKey())": self.toDictionary()]
      gDataBaseRef.updateChildValues(childUpdates, withCompletionBlock: { (error, _) in
         if let error = error {
            print("Error while synchronize item: \(error.localizedDescription)")
            completion(false)
         } else {
            completion(true)
         }
      })
   }
   
   // Save new data to the Firebase database
   private func save(completion: @escaping (Bool) -> Void) {
      let key = gDataBaseRef.child(self.tableName).childByAutoId().key
      self.setPrimaryKey(key)
      update(completion: completion)
   }
   
   func remove() {
      if self.primaryKey().isEmpty {
         return
      }
      let recordRef = gDataBaseRef.child(self.tableName).child(self.primaryKey()).queryOrdered(byChild: "\\")
      recordRef.observeSingleEvent(of: .value) { (snapshot) in
         let ref = snapshot.ref
         ref.removeValue()
      }
   }
}
