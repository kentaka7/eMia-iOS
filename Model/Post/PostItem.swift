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
   
   convenience init(_ snapshot: DataSnapshot) {
      self.init()
      key = snapshot.key
      if let dict = snapshot.value as? [String: AnyObject] {
         self.id = dict[PostItemFields.id] as? String ?? ""
         self.uid = dict[PostItemFields.uid] as? String ?? ""
         self.author = dict[PostItemFields.author] as? String ?? ""
         self.title = dict[PostItemFields.title] as? String ?? ""
         self.body = dict[PostItemFields.body] as? String ?? ""
         self.created = dict[PostItemFields.created] as? TimeInterval ?? 0
         self.photosize = dict[PostItemFields.photosize] as? String ?? ""
         self.starCount = dict[PostItemFields.starCount] as? Int ?? 0
      }
   }
   
   func toDictionary() -> [String : Any] {
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
      gFireBaseManager.firebaseRef.updateChildValues(childUpdates, withCompletionBlock: { (_, _) in
         completion(true)
      })
   }
   
   // Save new data to Firebase Database
   private func save(completion: @escaping (Bool) -> Void) {
      let key = gFireBaseManager.firebaseRef.child(PostItemFields.posts).childByAutoId().key
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

