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
   
   @objc dynamic var id: String?
   @objc dynamic var uid: String = ""
   @objc dynamic var postid: String = ""
   
   override class func primaryKey() -> String? {
      return "id"
   }
   
   convenience init(uid: String, postid: String, id: String? = nil) {
      self.init()
      self.id = id
      self.uid = uid
      self.postid = postid
   }
   
   convenience init(item: FavoriteItem) {
      self.init(uid: item.uid, postid: item.postid, id: item.id)
   }
   
   func copy(_ rhs: FavoriteModel) {
      self.id = rhs.id
      self.uid = rhs.uid
      self.postid = rhs.postid
   }
   
   func remove() {
      FavoriteItem(self).remove()
   }
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      FavoriteItem.save(self, completion: completion)
   }
}

extension FavoriteModel: IdentifiableType {

   typealias Identity = String
   
   var identity: Identity {
      return id ?? "0"
   }
}

func == (lhs: FavoriteModel, rhs: FavoriteModel) -> Bool {
   return lhs.uid == rhs.uid && lhs.postid == rhs.postid
}
