//
//  FavoritsManager.swift
//  eMia
//

import UIKit

class FavoritsManager: NSObject {
   
   class func isFavorite(for userId: String, postid: String) -> Bool {
      return FavoriteModel.favorities.index(where: {$0.postid == postid && $0.uid == userId}) != nil
   }

   class func addToFavorite(post: PostModel) {
      guard let currentUser = gUsersManager.currentUser else {
         return
      }
      guard let postId = post.id else {
         return
      }
      let newRecord = FavoriteModel(uid: currentUser.userId, postid: postId)
      let existedRecord = FavoriteModel.favorities.filter { $0 == newRecord }.first
      if let record = existedRecord {
         record.remove()
      } else {
         newRecord.synchronize { _ in
            gPushNotificationsCenter.send(.like(post: post)) {}
         }
      }
   }
   
   class func isItMyFavoritePost(_ post: PostModel) -> Bool {
      guard let currentUser = gUsersManager.currentUser else {
         return false
      }
      guard let postId = post.id else {
         return false
      }
      return self.isFavorite(for: currentUser.userId, postid: postId)
   }
}
