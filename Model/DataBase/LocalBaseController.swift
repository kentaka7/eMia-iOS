//
//  LocalBaseController.swift
//  eMia
//
//  Created by Sergey Krotkih on 17/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

class LocalBaseController {
   
   var isDataBaseFetched: Bool {
      return self.posts.count > 0
   }
   
   // MARK: Users
   
   var users: [UserModel] {
      return getAllData()
   }
   
   func addUser(_ item: UserItem) {
      let model = UserModel(item: item)
      guard model.userId.isEmpty == false else {
         return
      }
      create(model: model)
   }
   
   func deleteUser(_ item: UserItem) {
      if let model = getUser(for: item) {
         Realm.delete(model: model)
      }
   }
   
   func editUser(_  item: UserItem) {
      self.addUser(item)
   }

   // MARK: Post
   
   var posts: [PostModel] {
      return getAllData()
   }
   
   func addPost(_ item: PostItem) {
      let model = PostModel(item: item)
      guard let modelId = model.id, modelId.isEmpty == false else {
         return
      }
      create(model: model)
   }
   
   func deletePost(_ item: PostItem) {
      if let model = getPost(for: item) {
         Realm.delete(model: model)
      }
   }
   
   func editPost(_  item: PostItem) {
      addPost(item)
   }
   
   private func postsObservable() -> Observable<Results<PostModel>> {
      let result = Realm.withRealm("getting posts") { realm -> Observable<Results<PostModel>> in
         let realm = try Realm()
         let posts = realm.objects(PostModel.self)
         return Observable.collection(from: posts)
      }
      return result ?? .empty()
   }
   
   // MARK: Comments
   
   func addComment(_ item: CommentItem) {
      guard item.id.isEmpty == false else {
         return
      }
      let model = CommentModel(item: item)
      create(model: model)
   }
   
   func deleteComment(_ item: CommentItem) {
      if let model = getComment(for: item) {
         Realm.delete(model: model)
      }
   }
   
   func editComment(_  item: CommentItem) {
      addComment(item)
   }
   
   // MARK: Favorities

   var favorities: [FavoriteModel] {
      return getAllData()
   }
   
   func addFavorite(_ item: FavoriteItem) {
      guard item.id.isEmpty == false else {
         return
      }
      let model = FavoriteModel(item: item)
      create(model: model)
   }
   
   func deleteFavorite(_ item: FavoriteItem) {
      if let model = getFavorite(for: item) {
         Realm.delete(model: model)
      }
   }
   
   func editFavorite(_  item: FavoriteItem) {
      addFavorite(item)
   }

}

// MARK: - Private Methods

extension LocalBaseController {

   private func getAllData<T: Object>() -> [T] {
      do {
         let realm = try Realm()
         let results = realm.objects(T.self)
         return results.toArray()
      } catch let err {
         print("Failed read realm user data with error: \(err)")
         return []
      }
   }

   private func create<T: Object>(model: T) {
      _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
      }, onError: { error in
         Alert.default.showError(message: error.localizedDescription)
      })
   }
   
   // MARK: Get Object

   private func getUser(for item: UserItem) -> UserModel? {
      let filter = "userId = '\(item.userId)'"
      return getObject(with: filter)
   }

   private func getFavorite(for item: FavoriteItem) -> FavoriteModel? {
      let filter = "postid = '\(item.postid)' AND uid = '\(item.uid)'"
      return getObject(with: filter)
   }
   
   private func getComment(for item: CommentItem) -> CommentModel? {
      let filter = "id = '\(item.id)'"
      return getObject(with: filter)
   }
   
   private func getPost(for item: PostItem) -> PostModel? {
      let filter = "id = '\(item.id)'"
      return getObject(with: filter)
   }

   private func getObject<T: Object>(with filter: String) -> T? {
      do {
         let realm = try Realm()
         let data = realm.objects(T.self).filter(filter)
         return data.first
      } catch _ {
         return nil
      }
   }
}
