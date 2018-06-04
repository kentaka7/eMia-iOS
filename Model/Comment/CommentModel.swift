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

   static var rxComments = Variable<[CommentModel]>([])
   static var rxNewCommentObserved = Variable<CommentModel?>(nil)

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

   class var comments: [CommentModel] {
      do {
         let realm = try Realm()
         let comms = realm.objects(CommentModel.self)
         return comms.toArray().sorted(by: {$0.created > $1.created})
      } catch _ {
         return []
      }
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
   class func createRealm(model: CommentModel) -> Observable<CommentModel> {
      let result = DataModelInteractor.withRealm("creating") { realm -> Observable<CommentModel> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(PostServiceError.creationFailed)
   }
}

extension CommentModel {
   
   class func addComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if let _ = commentIndex(of: model) {
         return
      } else if !item.id.isEmpty {
         _ = CommentModel.createRealm(model: model)
         rxComments.value.append(model)
         // TODO: Remove it
         rxNewCommentObserved.value = model
      }
   }
   
   class func deleteComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         rxComments.value.remove(at: index)
      }
   }
   
   class func editComment(_  item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         //_ = FavoriteModel.createRealm(model: model)
         rxComments.value[index] = model
      }
   }
   
   class func commentIndex(of model: CommentModel) -> Int? {
      let index = comments.index(where: {$0 == model})
      return index
   }
}

extension CommentModel: IdentifiableType {
   typealias Identity = String
   
   var identity : Identity {
      return id ?? ""
   }
}

extension CommentModel {
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      let commentItem = CommentItem(uid: uid, author: author, text: text, postid: postid, created: created)
      commentItem.key = key ?? ""
      commentItem.id = id ?? ""
      commentItem.synchronize(completion: completion)
   }
}

func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
   return lhs.id == rhs.id
}
