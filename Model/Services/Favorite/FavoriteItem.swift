//
//  FavoriteItem.swift
//  eMia
//

import UIKit
import Firebase

class FavoriteItem: FirebaseStorable {

   static let TableName = "favorites"
   
   var tableName: String {
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
   
   init() {
      self.id = ""
      self.uid = ""
      self.postid = ""
   }
   
   convenience init(_ model: FavoriteModel) {
      self.init()
      self.uid = model.uid
      self.postid = model.postid
      self.id = model.id ?? ""
      self.id = model.id == nil || model.id!.isEmpty ? "" : self.id
   }
   
   required convenience init?(_ snapshot: DataSnapshot) {
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
   
   func toDictionary() -> [String: Any] {
      return [
         FavoriteItem.Fields.id: id,
         FavoriteItem.Fields.uid: uid,
         FavoriteItem.Fields.postid: postid
      ]
   }
   
   func primaryKey() -> String {
      return self.id
   }
   
   func setPrimaryKey(_ key: String) {
      self.id = key
   }
}
