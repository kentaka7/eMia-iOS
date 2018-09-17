//
//  FavoritsManager.swift
//  eMia
//
//  Created by Sergey Krotkih on 16/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

struct FavoritsManager {

   func getAllFavorities() -> [FavoriteModel] {
      return LocalBaseController().favorities
   }

   private func getModel(for userId: String, postid: String) -> FavoriteModel? {
      return getAllFavorities().filter({ (model) -> Bool in
         return model.postid == postid && model.uid == userId
      }).first
   }
   
   func isFavorite(for userId: String, postid: String) -> Bool {
      return getModel(for: userId, postid: postid) != nil
   }
   
   func addToFavorite(post: PostModel) {
      guard let currentUser = gUsersManager.currentUser else {
         return
      }
      guard let postId = post.id else {
         return
      }
      if let model = getModel(for: currentUser.userId, postid: postId) {
         model.remove()
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
}
