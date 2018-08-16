//
//  PostsManager.swift
//  eMia
//
//  Created by Сергей Кротких on 16/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

struct PostsManager {
   
   var posts: [PostModel] {
      do {
         let realm = try Realm()
         let posts = realm.objects(PostModel.self)
         return posts.toArray()
      } catch let err {
         print("Failed read realm user data with error: \(err)")
         return []
      }
   }

   func postsObservable() -> Observable<Results<PostModel>> {
      let result = Realm.withRealm("getting posts") { realm -> Observable<Results<PostModel>> in
         let realm = try Realm()
         let posts = realm.objects(PostModel.self)
         return Observable.collection(from: posts)
      }
      return result ?? .empty()
   }

   func isItMyPost(_ post: PostModel) -> Bool {
      guard let currentUser = gUsersManager.currentUser else {
         return false
      }
      return post.uid == currentUser.userId
   }
   
   func getPost(with postId: String) -> PostModel? {
      return posts.first(where: { $0.id == postId })
   }
}

// MARK: -

extension PostsManager {
   
   func addPost(_ item: PostItem) {
      let model = PostModel(item: item)
      guard let modelId = model.id, !modelId.isEmpty else {
         return
      }
      if postsIndex(of: model) != nil {
         return
      }
      _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
      }, onError: { error in
         Alert.default.showError(message: error.localizedDescription)
      })
   }
   
   func deletePost(_ item: PostItem) {
      let post = PostModel(item: item)
      if let index = postsIndex(of: post) {
         let model = posts[index]
         Realm.delete(model: model)
      }
   }
   
   func editPost(_  item: PostItem) {
      let model = PostModel(item: item)
      _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
      }, onError: { error in
         Alert.default.showError(message: error.localizedDescription)
      })
   }
   
   func postsIndex(of post: PostModel) -> Int? {
      let index = posts.index(where: {$0 == post})
      return index
   }
}
