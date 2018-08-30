//
//  FavoriteItem.swift
//  eMia
//

import UIKit
import Firebase

class FavoriteItem: FirebaseItem {

   static let TableName = "favorites"
   
   override var tableName: String {
      return FavoriteItem.TableName
   }

   struct Fields {
      static let id = "id"
      static let uid = "uid"
      static let postid = "postid"
   }

   var id: String
   var uid: String
   var postid: String
   
   override init() {
      self.id = ""
      self.uid = ""
      self.postid = ""
   }
   
   init(uid: String, postid: String, id: String? = nil) {
      self.id = id ?? ""
      self.uid = uid
      self.postid = postid
   }
   
   convenience init?(_ snapshot: DataSnapshot) {
      guard
         let snapshotValue = snapshot.value as? [String: AnyObject],
         let id = snapshotValue[CommentItem.Fields.id] as? String,
         let uid = snapshotValue[CommentItem.Fields.uid] as? String,
         let postid = snapshotValue[FavoriteItem.Fields.postid] as? String
         else {
            return nil
      }
      self.init()
      self.id = id
      self.uid = uid
      self.postid = postid
   }
   
   override func toDictionary() -> [String: Any] {
      return [
         FavoriteItem.Fields.id: id,
         FavoriteItem.Fields.uid: uid,
         FavoriteItem.Fields.postid: postid
      ]
   }
   
   override func primaryKey() -> String {
      return self.id
   }
   
   override func setPrimaryKey(_ key: String) {
      self.id = key
   }
}
