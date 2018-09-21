//
//  FirebaseStorable.swift
//  eMia
//
//  Created by Sergey Krotkih on 29/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseStorable {
   init?(_ snapshot: DataSnapshot)
   func primaryKey() -> String
   func setPrimaryKey(_ key: String)
   func toDictionary() -> [String: Any]
   var tableName: String { get }
}

//

extension FirebaseStorable {

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

extension FirebaseStorable where Self: UserItem {
   
   static func save(_ model: UserModel, completion: @escaping (Bool) -> ()) {
      let userItem = UserItem(model)
      userItem.synchronize(completion: completion)
   }
}

extension FirebaseStorable where Self: PostItem {

   static func save(_ model: PostModel, completion: @escaping (String) -> ()) {
      let postItem = PostItem(model)
      postItem.synchronize { _ in
         completion(postItem.id)
      }
   }
}

extension FirebaseStorable where Self: CommentItem {
   
   static func save(_ model: CommentModel, completion: @escaping (Bool) -> ()) {
      CommentItem(model).synchronize(completion: completion)
   }
}

extension FirebaseStorable where Self: FavoriteItem {
   
   static func save(_ model: FavoriteModel, completion: @escaping (Bool) -> ()) {
      FavoriteItem(model).synchronize(completion: completion)
   }
}
