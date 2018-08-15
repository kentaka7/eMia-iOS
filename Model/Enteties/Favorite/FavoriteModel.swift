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
   
   @objc dynamic var key: String?
   @objc dynamic var id: String?
   @objc dynamic var uid: String = ""
   @objc dynamic var postid: String = ""

   class var favorities: [FavoriteModel] {
      do {
         let realm = try Realm()
         let favs = realm.objects(FavoriteModel.self)
         return favs.toArray()
      } catch _ {
         return []
      }
   }
   
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
      let item = FavoriteItem(uid: self.uid, postid: self.postid, key: self.key, id: self.id)
      item.remove()
   }
}

extension FavoriteModel {
   
   class func isFavorite(for userId: String, postid: String) -> Bool {
      return self.requestData(for: userId, postid: postid).count > 0
   }

   class func requestData(for userId: String, postid: String) -> [FavoriteModel] {
      do {
         let realm = try Realm()
         let data = realm.objects(FavoriteModel.self).filter("postid = '\(postid)' AND uid = '\(userId)'")
         return data.toArray()
      } catch _ {
         return []
      }
   }
   
   class func addToFavorite(post: PostModel) {
      guard let currentUser = gUsersManager.currentUser else {
         return
      }
      guard let postId = post.id else {
         return
      }
      let data = self.requestData(for: currentUser.userId, postid: postId)
      if data.count > 0 {
         for model in data {
            model.remove()
         }
      } else {
         let newRecord = FavoriteModel(uid: currentUser.userId, postid: postId)
         newRecord.synchronize { _ in
            gPushNotificationsCenter.send(.like(post: post)) {}
         }
      }
   }
   
   class func isItMyFavoritePost(_ post: PostModel) -> Bool {
      guard let currentUser = gUsersManager.currentUser else {
         return false
      }
      guard let postId = post.id else {
         return false
      }
      return self.isFavorite(for: currentUser.userId, postid: postId)
   }

}

extension FavoriteModel {
   
   class func addFavorite(_ item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if favoritiesIndex(of: model) != nil {
         return
      }
      if item.id.isEmpty == false {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   class func deleteFavorite(_ item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if let index = favoritiesIndex(of: model) {
         let model = favorities[index]
         Realm.delete(model: model)
      }
   }
   
   class func editFavorite(_  item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if let _ = favoritiesIndex(of: model) {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   class func favoritiesIndex(of model: FavoriteModel) -> Int? {
      let index = favorities.index(where: {$0 == model})
      return index
   }
}

extension FavoriteModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
      return id ?? "0"
   }
}

extension FavoriteModel {
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      let favoriteItem = FavoriteItem(uid: uid, postid: postid)
      favoriteItem.key = key == nil || key!.isEmpty ? "" : favoriteItem.key
      favoriteItem.id = id == nil || id!.isEmpty ? "" : favoriteItem.id
      favoriteItem.synchronize(completion: completion)
   }
}

func == (lhs: FavoriteModel, rhs: FavoriteModel) -> Bool {
   return lhs.uid == rhs.uid && lhs.postid == rhs.postid
}
