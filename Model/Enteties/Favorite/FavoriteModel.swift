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
