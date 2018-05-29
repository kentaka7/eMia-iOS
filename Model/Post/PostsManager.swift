//
//  FavoritsManager.swift
//  eMia
//

import UIKit
import RxSwift

internal let PostsManager = PostsDataBaseInteractor.sharedInstance

class PostsDataBaseInteractor: NSObject {
   
   static let sharedInstance: PostsDataBaseInteractor = {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      return appDelegate.postsManager
   }()
   
   func isItMyPost(_ post: PostModel) -> Bool {
      guard let currentUser = UsersManager.currentUser else {
         return false
      }
      return post.uid == currentUser.userId
   }
   
   func getPost(with postId: String) -> PostModel? {
      return DataModel.posts.first(where: { $0.id == postId })
   }
}
