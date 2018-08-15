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

   static var rxComments = BehaviorSubject<[CommentModel]>(value: [])
   static var rxNewCommentObserved = BehaviorSubject<CommentModel?>(value: nil)

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
         return comms.toArray()
      } catch _ {
         return []
      }
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

extension CommentModel {
   
   class func addComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if commentIndex(of: model) != nil {
         return
      }
      if !item.id.isEmpty {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
            try? rxComments.onNext(rxComments.value() + [model])
            // TODO: Remove it
            rxNewCommentObserved.onNext(model)
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   class func deleteComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         let model = comments[index]
         Realm.delete(model: model)
         do {
            var array = try rxComments.value()
            array.remove(at: index)
            rxComments.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func editComment(_  item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
            do {
               var array = try rxComments.value()
               array[index] = model
               rxComments.onNext(array)
            } catch {
               print(error)
            }
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   class func commentIndex(of model: CommentModel) -> Int? {
      let index = comments.index(where: {$0 == model})
      return index
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
