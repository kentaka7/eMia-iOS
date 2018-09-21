//
//  CommentItem.swift
//  eMia
//

import UIKit
import Firebase

class CommentItem: FirebaseStorable {
   
   static let TableName = "comments"
   
   var tableName: String {
      return CommentItem.TableName
   }

   struct Fields {
      static let id = "id"
      static let uid = "uid"
      static let author = "author"
      static let text = "text"
      static let postid = "postid"
      static let created = "created"
   }

   var id: String
   var uid: String
   var author: String
   var text: String
   var postid: String
   var created: Double
   
   init() {
      self.id = ""
      self.uid = ""
      self.author = ""
      self.text = ""
      self.postid = ""
      self.created = 0
   }
   
   convenience init(_ model: CommentModel) {
      self.init()
      self.uid = model.uid
      self.author = model.author
      self.text = model.text
      self.postid = model.postid
      self.created = model.created
      self.id = model.id ?? ""
   }
   
   required convenience init?(_ snapshot: DataSnapshot) {
      guard
         let snapshotValue = snapshot.value as? [String: AnyObject],
         let id = snapshotValue[CommentItem.Fields.id] as? String,
         let uid = snapshotValue[CommentItem.Fields.uid] as? String,
         let author = snapshotValue[CommentItem.Fields.author] as? String
         else {
            return nil
      }
      self.init()
      self.id = id
      self.uid = uid
      self.author = author
      self.text = snapshotValue[CommentItem.Fields.text] as? String ?? ""
      self.postid = snapshotValue[CommentItem.Fields.postid] as? String ?? ""
      self.created = snapshotValue[CommentItem.Fields.created] as? TimeInterval ?? 0
   }
   
   func toDictionary() -> [String: Any] {
      return [
         CommentItem.Fields.id: id,
         CommentItem.Fields.uid: uid,
         CommentItem.Fields.author: author,
         CommentItem.Fields.text: text,
         CommentItem.Fields.postid: postid,
         CommentItem.Fields.created: created
      ]
   }
   
   func primaryKey() -> String {
      return self.id
   }
   
   func setPrimaryKey(_ key: String) {
      self.id = key
   }
}
