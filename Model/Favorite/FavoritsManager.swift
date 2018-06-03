//
//  FavoritsManager.swift
//  eMia
//

import UIKit

internal let FavoritsManager = FavoritsDataBaseInteractor.sharedInstance

class FavoritsDataBaseInteractor: NSObject {

   static let sharedInstance: FavoritsDataBaseInteractor = {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      return appDelegate.favoritsManager
   }()
   
   override init() {
      super.init()
   }

   func isFavorite(for userId: String, postid: String) -> Bool {
      let model = FavoriteModel(uid: userId, postid: postid)
      if let _ = self.index(of: model) {
         return true
      }
      return false
   }

   func addToFavorite(post: PostModel) {
      guard let postId = post.id else {
         return
      }
      if let currentUser = UsersManager.currentUser {
         let model = FavoriteModel(uid: currentUser.userId, postid: postId)
         if let index = self.index(of: model) {
            let model = FavoriteModel.favorities[index]
            model.remove()
         } else {
            model.synchronize() { _ in
               PushNotificationsCenter.send(.like(post: post)) {
               }
            }
         }
      }
   }
   
   func isItMyFavoritePost(_ post: PostModel) -> Bool {
      guard let currentUser = UsersManager.currentUser else {
         return false
      }
      guard let postId = post.id else {
         return false
      }
      let myId = currentUser.userId
      if let _ = FavoriteModel.favorities.index(where: {$0.postid == postId && $0.uid == myId}) {
         return true
      } else {
         return false
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
