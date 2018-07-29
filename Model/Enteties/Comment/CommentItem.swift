//
//  CommentItem.swift
//  eMia
//

import UIKit
import Firebase

// MARK: - CommentItem

class CommentItem: NSObject, NSCoding {
   var key: String
   var id: String
   var uid: String
   var author: String
   var text: String
   var postid: String
   var created: Double
   
   override init() {
      self.key = ""
      self.id = ""
      self.uid = ""
      self.author = ""
      self.text = ""
      self.postid = ""
      self.created = 0
      super.init()
   }
   
   convenience init(uid: String, author: String, text: String, postid: String, created: Double) {
      self.init()
      self.uid = uid
      self.author = author
      self.text = text
      self.postid = postid
      self.created = created
   }
   
   required convenience init(coder decoder: NSCoder) {
      self.init()
      self.key = decoder.decodeObject(forKey: CommentItemFields.key) as? String ?? ""
      self.id = decoder.decodeObject(forKey: CommentItemFields.id) as? String ?? ""
      self.uid = decoder.decodeObject(forKey: CommentItemFields.uid) as? String ?? ""
      self.author = decoder.decodeObject(forKey: CommentItemFields.author) as? String ?? ""
      self.text = decoder.decodeObject(forKey: CommentItemFields.text) as? String ?? ""
      self.postid = decoder.decodeObject(forKey: CommentItemFields.postid) as? String ?? ""
      self.created = decoder.decodeObject(forKey: CommentItemFields.created) as? TimeInterval ?? 0
   }
   
   func encode(with coder: NSCoder) {
      coder.encode(key, forKey: CommentItemFields.key)
      coder.encode(id, forKey: CommentItemFields.id)
      coder.encode(uid, forKey: CommentItemFields.uid)
      coder.encode(author, forKey: CommentItemFields.author)
      coder.encode(text, forKey: CommentItemFields.text)
      coder.encode(postid, forKey: CommentItemFields.postid)
      coder.encode(created, forKey: CommentItemFields.created)
   }
   
   convenience init?(_ snapshot: DataSnapshot) {
      if let dict = snapshot.value as? [String: AnyObject] {
         self.init()
         key = snapshot.key
         //      ref = snapshot.ref
         self.id = dict[CommentItemFields.id] as? String ?? ""
         self.uid = dict[CommentItemFields.uid] as? String ?? ""
         self.author = dict[CommentItemFields.author] as? String ?? ""
         self.text = dict[CommentItemFields.text] as? String ?? ""
         self.postid = dict[CommentItemFields.postid] as? String ?? ""
         self.created = dict[CommentItemFields.created] as? TimeInterval ?? 0
      } else {
         return nil
      }
   }
   
   func toDictionary() -> [String: Any] {
      return [
         CommentItemFields.id: id,
         CommentItemFields.uid: uid,
         CommentItemFields.author: author,
         CommentItemFields.text: text,
         CommentItemFields.postid: postid,
         CommentItemFields.created: created
      ]
   }
}

// MARK: - Save record

extension CommentItem {

   func synchronize(completion: @escaping (Bool) -> Void) {
      if self.key.isEmpty {
         save(completion: completion)
      } else {
         update(completion: completion)
      }
   }
   
   // Update exists data to Firebase Database
   private func update(completion: @escaping (Bool) -> Void) {
      let childUpdates = ["/\(CommentItemFields.comments)/\(self.id)": self.toDictionary()]
      gDataBaseRef.updateChildValues(childUpdates, withCompletionBlock: { (_, _) in
         completion(true)
      })
   }
   
   // Save new data to Firebase Database
   private func save(completion: @escaping (Bool) -> Void) {
      let key = gDataBaseRef.child(CommentItemFields.comments).childByAutoId().key
      self.key = key
      self.id = key
      self.created = Date().timeIntervalSince1970
      update(completion: completion)
   }
   
   func remove() {
//      self.ref?.removeValue()
   }
}

// MARK: -

func == (lhs: CommentItem, rhs: CommentItem) -> Bool {
   let result = lhs.id == rhs.id
   return result
}
