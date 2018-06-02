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
   
   @objc dynamic var key: String? = nil
   @objc dynamic var id: String? = nil
   
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
      self.key = rhs.key
      self.id = rhs.id
      self.uid = rhs.uid
      self.author = rhs.author
      self.text = rhs.text
      self.postid = rhs.postid
      self.created = rhs.created
   }
   
   @discardableResult
   class func createComment(item: CommentItem) -> Observable<CommentModel> {
      let result = FetchingWorker.withRealm("creating") { realm -> Observable<CommentModel> in
         let commentModel = CommentModel(item: item)
         try realm.write {
            realm.add(commentModel)
         }
         return .just(commentModel)
      }
      return result ?? .error(EmiaServiceError.creationFailed)
   }
}
extension CommentModel: IdentifiableType {
   typealias Identity = String
   
   var identity : Identity {
      return id ?? "0"
   }
}

extension CommentModel {
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      let commentItem = CommentItem(uid: uid, author: author, text: text, postid: postid, created: created)
      commentItem.key = key ?? "0"
      commentItem.id = id ?? "0"
      commentItem.synchronize(completion: completion)
   }
}

func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
   return lhs.id == rhs.id
}
