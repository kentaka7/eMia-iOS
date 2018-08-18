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
      let realm = try? Realm()
      let results = realm?.objects(PostModel.self).filter("id = '\(postId)'")
      return results?.first
   }
}
