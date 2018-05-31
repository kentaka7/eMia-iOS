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
      let item = FavoriteItem(uid: userId, postid: postid)
      if let _ = self.index(of: item) {
         return true
      }
      return false
   }

   func addToFavorite(post: PostModel) {
      guard let postId = post.id else {
         return
      }
      if let currentUser = UsersManager.currentUser {
         let item = FavoriteItem(uid: currentUser.userId, postid: postId)
         if let index = self.index(of: item) {
            let item = DataModel.favorities.value[index]
            item.remove()
         } else {
            item.synchronize() { _ in
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
      if let _ = DataModel.favorities.value.index(where: {$0.postid == postId && $0.uid == myId}) {
         return true
      } else {
         return false
      }
   }
}

// MARK: - Private

extension FavoritsDataBaseInteractor {
   
   fileprivate func index(of favorite: FavoriteItem) -> Int? {
      for index in 0..<DataModel.favorities.value.count {
         let item = DataModel.favorities.value[index]
         if favorite == item {
            return index
         }
      }
      return nil
   }
}
