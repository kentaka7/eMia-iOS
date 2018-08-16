//
//  CommentModel.swift
//  eMia
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxRealm

final class CommentModel: Object {
   
   @objc dynamic var key: String?
   @objc dynamic var id: String?
   
   @objc dynamic var uid: String = ""
   @objc dynamic var author: String = ""
   @objc dynamic var text: String = ""
   @objc dynamic var postid: String = ""
   @objc dynamic var created: Double = 0

   override class func primaryKey() -> String? {
      return "id"
   }
   
   convenience init(uid: String, author: String, text: String, postid: String, created: Double? = nil, key: String? = nil, id: String? = nil) {
      self.init()
      self.key = key
      self.id = id
      self.uid = uid
      self.author = author
      self.text = text
      self.postid = postid
      self.created = created ?? Date().timeIntervalSince1970
   }
   
   convenience init(item: CommentItem) {
      self.init(uid: item.uid, author: item.author, text: item.text, postid: item.postid, created: item.created, key: item.key, id: item.id)
   }
   
   func copy(_ rhs: CommentModel) {
      key = rhs.key
      id = rhs.id
      uid = rhs.uid
      author = rhs.author
      text = rhs.text
      postid = rhs.postid
      created = rhs.created
   }
}

extension CommentModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
      return id ?? ""
   }
}

extension CommentModel {
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      let commentItem = CommentItem(uid: self.uid, author: self.author, text: self.text, postid: self.postid, created: self.created)
      commentItem.key = key ?? ""
      commentItem.id = id ?? ""
      commentItem.synchronize(completion: completion)
   }
}

extension CommentModel {
   func relativeTimeToCreated() -> String {
      let date = Date(timeIntervalSince1970: self.created)
      return date.relativeTime
   }
}

func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
   return lhs.id == rhs.id
}
