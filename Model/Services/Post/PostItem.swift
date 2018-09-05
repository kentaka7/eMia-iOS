//
//  PostItem.swift
//  eMia
//

import UIKit
import Firebase

class PostItem: FirebaseItem {

   static let TableName = "posts"
   
   override var tableName: String {
      return PostItem.TableName
   }
   
   struct Fields {
      static let id = "id"
      static let uid = "uid"
      static let author = "author"
      static let title = "title"
      static let body = "body"
      static let created = "created"
      static let portrait = "portrait"
      static let photosize = "photosize"
      static let starCount = "starCount"
   }

   var id: String
   
   var uid: String
   var author: String
   var title: String
   var body: String
   var created: Double
   var photosize: String
   var starCount: Int
   
   override init() {
      self.id = ""
      
      self.uid = ""
      self.author = ""
      self.title = ""
      self.body = ""
      self.created = 0
      self.photosize = ""
      self.starCount = 0
   }
   
   convenience init(uid: String, author: String, title: String, body: String, photosize: String, starCount: Int, created: Double) {
      self.init()
      self.uid = uid
      self.author = author
      self.title = title
      self.body = body
      self.created = created
      self.photosize = photosize
      self.starCount = starCount
   }
   
   convenience init?(_ snapshot: DataSnapshot) {
      guard
         let snapshotValue = snapshot.value as? [String: AnyObject],
         let id = snapshotValue[PostItem.Fields.id] as? String,
         let uid = snapshotValue[PostItem.Fields.uid] as? String,
         let author = snapshotValue[PostItem.Fields.author] as? String
         else {
            return nil
      }
      self.init()
      self.id = id
      self.uid = uid
      self.author = author
      title = snapshotValue[PostItem.Fields.title] as? String ?? ""
      body = snapshotValue[PostItem.Fields.body] as? String ?? ""
      created = snapshotValue[PostItem.Fields.created] as? TimeInterval ?? 0
      photosize = snapshotValue[PostItem.Fields.photosize] as? String ?? ""
      starCount = snapshotValue[PostItem.Fields.starCount] as? Int ?? 0
   }
   
   static func decodeSnapshot(_ snapshot: DataSnapshot) -> PostItem? {
      let item = PostItem(snapshot)
      return item
   }

   override func toDictionary() -> [String: Any] {
      return [
         PostItem.Fields.id: id,
         PostItem.Fields.uid: uid,
         PostItem.Fields.author: author,
         PostItem.Fields.title: title,
         PostItem.Fields.body: body,
         PostItem.Fields.created: created,
         PostItem.Fields.photosize: photosize,
         PostItem.Fields.starCount: starCount
      ]
   }
   
   override func primaryKey() -> String {
      return self.id
   }
   
   override func setPrimaryKey(_ key: String) {
      self.id = key
   }
   
}
