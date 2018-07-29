//
//  PostItem.swift
//  eMia
//

import UIKit
import Firebase

// MARK: - PostItem

class PostItem: NSObject {
   
   var key: String
   var id: String
   
   var uid: String
   var author: String
   var title: String
   var body: String
   var created: Double
   var photosize: String
   var starCount: Int
   
   override init() {
      self.key = ""
      self.id = ""
      
      self.uid = ""
      self.author = ""
      self.title = ""
      self.body = ""
      self.created = 0
      self.photosize = ""
      self.starCount = 0
      super.init()
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
      if let dict = snapshot.value as? [String: AnyObject] {
         self.init()
         key = snapshot.key
         id = dict[PostItemFields.id] as? String ?? ""
         uid = dict[PostItemFields.uid] as? String ?? ""
         author = dict[PostItemFields.author] as? String ?? ""
         title = dict[PostItemFields.title] as? String ?? ""
         body = dict[PostItemFields.body] as? String ?? ""
         created = dict[PostItemFields.created] as? TimeInterval ?? 0
         photosize = dict[PostItemFields.photosize] as? String ?? ""
         starCount = dict[PostItemFields.starCount] as? Int ?? 0
      } else {
         return nil
      }
   }
   
   func toDictionary() -> [String: Any] {
      return [
         PostItemFields.id: id,
         PostItemFields.uid: uid,
         PostItemFields.author: author,
         PostItemFields.title: title,
         PostItemFields.body: body,
         PostItemFields.created: created,
         PostItemFields.photosize: photosize,
         PostItemFields.starCount: starCount
      ]
   }
   
   class func decodeSnapshot(_ snapshot: DataSnapshot) -> PostItem? {
      let item = PostItem(snapshot)
      return item
   }
}

// MARK: - Save record

extension PostItem {
   
   func synchronize(completion: @escaping (Bool) -> Void) {
      if self.key.isEmpty {
         save(completion: completion)
      } else {
         update(completion: completion)
      }
   }
   
   // Update exists data to Firebase Database
   private func update(completion: @escaping (Bool) -> Void) {
      let childUpdates = ["/\(PostItemFields.posts)/\(self.key)": self.toDictionary()]
      gDataBaseRef.updateChildValues(childUpdates, withCompletionBlock: { (_, _) in
         completion(true)
      })
   }
   
   // Save new data to Firebase Database
   private func save(completion: @escaping (Bool) -> Void) {
      let key = gDataBaseRef.child(PostItemFields.posts).childByAutoId().key
      self.key = key
      self.id = key
      update(completion: completion)
   }
   
   func remove() {
      //        self.ref?.removeValue()
   }
}

// MARK: -

func == (lhs: PostItem, rhs: PostItem) -> Bool {
   let result = lhs.id == rhs.id
   return result
}
