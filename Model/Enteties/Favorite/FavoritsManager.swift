//
//  FavoritsManager.swift
//  eMia
//
//  Created by Сергей Кротких on 16/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

struct FavoritsManager {

   var favorities: [FavoriteModel] {
      do {
         let realm = try Realm()
         let favs = realm.objects(FavoriteModel.self)
         return favs.toArray()
      } catch _ {
         return []
      }
   }

   func isFavorite(for userId: String, postid: String) -> Bool {
      return self.requestData(for: userId, postid: postid).count > 0
   }
   
   func requestData(for userId: String, postid: String) -> [FavoriteModel] {
      do {
         let realm = try Realm()
         let data = realm.objects(FavoriteModel.self).filter("postid = '\(postid)' AND uid = '\(userId)'")
         return data.toArray()
      } catch _ {
         return []
      }
   }
   
   func addToFavorite(post: PostModel) {
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
   
   func isItMyFavoritePost(_ post: PostModel) -> Bool {
      guard let currentUser = gUsersManager.currentUser else {
         return false
      }
      guard let postId = post.id else {
         return false
      }
      return self.isFavorite(for: currentUser.userId, postid: postId)
   }

   func addFavorite(_ item: FavoriteItem) {
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
   
   func deleteFavorite(_ item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if let index = favoritiesIndex(of: model) {
         let model = favorities[index]
         Realm.delete(model: model)
      }
   }
   
   func editFavorite(_  item: FavoriteItem) {
      let model = FavoriteModel(item: item)
      if let _ = favoritiesIndex(of: model) {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   func favoritiesIndex(of model: FavoriteModel) -> Int? {
      let index = favorities.index(where: {$0 == model})
      return index
   }
   
}
