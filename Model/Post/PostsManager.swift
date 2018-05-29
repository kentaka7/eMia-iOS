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
   
   var isUpdated : Observable<Bool> {
      let ob1 = DataModel.postWasAdded.asObservable()
      let ob2 = DataModel.postWasRemoved.asObservable()
      let ob3 = DataModel.postWasUpdated.asObservable()
      return Observable.combineLatest(ob1, ob2, ob3){ b1, b2, b3 in
         b1 || b2 || b3
      }
   }
   
   func getData() -> [PostModel] {
      let posts = DataModel.posts
      return posts.sorted(by: {$0.created > $1.created})
   }
   
   func isItMyPost(_ post: PostModel) -> Bool {
      guard let currentUser = UsersManager.currentUser else {
         return false
      }
      return post.uid == currentUser.userId
   }
   
   func getPost(with postId: String) -> PostModel? {
      return self.getData().first(where: { $0.id == postId })
   }
   
}
