//
//  FavoritsManager.swift
//  eMia
//

import UIKit

internal let gFavoritsManager = FavoritsDataBaseInteractor.sharedInstance

class FavoritsDataBaseInteractor: NSObject {

   static let sharedInstance: FavoritsDataBaseInteractor = {
      return AppDelegate.instance.favoritsManager
   }()
   
   override init() {
      super.init()
   }

   func isFavorite(for userId: String, postid: String) -> Bool {
      let model = FavoriteModel(uid: userId, postid: postid)
      return self.index(of: model) != nil
   }

   func addToFavorite(post: PostModel) {
      guard let postId = post.id else {
         return
      }
      if let currentUser = gUsersManager.currentUser {
         let model = FavoriteModel(uid: currentUser.userId, postid: postId)
         if let index = self.index(of: model) {
            let model = FavoriteModel.favorities[index]
            model.remove()
         } else {
            model.synchronize { _ in
               gPushNotificationsCenter.send(.like(post: post)) {
               }
            }
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
      let myId = currentUser.userId
      if FavoriteModel.favorities.index(where: {$0.postid == postId && $0.uid == myId}) == nil {
         return false
      } else {
         return true
      }
   }
}

// MARK: - Private

extension FavoritsDataBaseInteractor {
   
   fileprivate func index(of favorite: FavoriteModel) -> Int? {
      for index in 0..<FavoriteModel.favorities.count {
         let model = FavoriteModel.favorities[index]
         if favorite == model {
            return index
         }
      }
      return nil
   }
}
