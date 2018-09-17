//
//  PostsManager.swift
//  eMia
//
//  Created by Sergey Krotkih on 16/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

struct PostsManager {

   func isItMyPost(_ post: PostModel) -> Bool {
      guard let currentUser = gUsersManager.currentUser else {
         return false
      }
      return post.uid == currentUser.userId
   }

   func getAllPosts() -> [PostModel] {
      return LocalBaseController().posts
   }
   
   func getPost(with postId: String) -> PostModel? {
      return getAllPosts().first(where: { (postModel) -> Bool in
         if let id = postModel.id {
            return id == postId
         } else {
            return false
         }
      })
   }
}
