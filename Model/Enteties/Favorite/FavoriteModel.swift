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

   static var rxFavorities = BehaviorSubject<[FavoriteModel]>(value: [])
   
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
      let item = FavoriteItem(uid: uid, postid: postid, key: key, id: id)
      item.remove()
   }
   
   @discardableResult
   class func createRealm(model: FavoriteModel) -> Observable<FavoriteModel> {
      let result = DataBaseImpl.withRealm("creating") { realm -> Observable<FavoriteModel> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(PostServiceError.creationFailed)
   }
}

extension FavoriteModel {
   
   class func addFavorite(_ item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if favoritiesIndex(of: model) != nil {
         return
      }
      if item.id.isEmpty == false {
         _ = FavoriteModel.createRealm(model: model)
         try? rxFavorities.onNext(rxFavorities.value() + [model])
      }
   }
   
   class func deleteFavorite(_ item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if let index = favoritiesIndex(of: model) {
         do {
            var array = try rxFavorities.value()
            array.remove(at: index)
            rxFavorities.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func editFavorite(_  item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if let index = favoritiesIndex(of: model) {
         //_ = FavoriteModel.createRealm(model: model)
         do {
            var array = try rxFavorities.value()
            array[index] = model
            rxFavorities.onNext(array)
         } catch {
            print(error)
         }
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
