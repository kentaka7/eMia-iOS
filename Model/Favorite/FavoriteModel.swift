//
//  FavoriteModel.swift
//  eMia
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxRealm

final class FavoriteModel: Object {
   
   @objc dynamic var key: String? = nil
   @objc dynamic var id: String? = nil
   @objc dynamic var uid: String = ""
   @objc dynamic var postid: String = ""

   override class func primaryKey() -> String? {
      return "id"
   }
   
   convenience init(uid: String, postid: String, key: String? = nil, id: String? = nil) {
      self.init()
      self.key = key
      self.id = id
      self.uid = uid
      self.postid = postid
   }
   
   convenience init(item: FavoriteItem) {
      self.init(uid: item.uid, postid: item.postid, key: item.key, id: item.id)
   }
   
   func copy(_ rhs: CommentModel) {
      self.key = rhs.key
      self.id = rhs.id
      self.uid = rhs.uid
      self.postid = rhs.postid
   }
   
   func remove() {
      let item = FavoriteItem(uid: uid, postid: postid, key: key, id: id)
      item.remove()
   }
   
   @discardableResult
   class func createFavorite(model: FavoriteModel) -> Observable<FavoriteModel> {
      let result = FetchingWorker.withRealm("creating") { realm -> Observable<FavoriteModel> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(EmiaServiceError.creationFailed)
   }
}

extension FavoriteModel: IdentifiableType {
   typealias Identity = String
   
   var identity : Identity {
      return id ?? "0"
   }
}

extension FavoriteModel {
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      let favoriteItem = FavoriteItem(uid: uid, postid: postid)
      favoriteItem.key = key ?? "0"
      favoriteItem.id = id ?? "0"
      favoriteItem.synchronize(completion: completion)
   }
}

func == (lhs: FavoriteModel, rhs: FavoriteModel) -> Bool {
   return lhs.id == rhs.id
}
