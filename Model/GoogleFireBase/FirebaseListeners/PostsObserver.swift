//
//  PostsObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class PostsObserver: FireBaseListener {
   lazy var dbRef = gDataBaseRef.child(PostItemFields.posts)
   private let disposeBag = DisposeBag()
   private let postsManager = PostsManager()

   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = PostItem(snapshot) {
               self.postsManager.addPost(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = PostItem(snapshot) {
               self.postsManager.deletePost(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = PostItem(snapshot) {
               self.postsManager.editPost(item)
            }
         }).disposed(by: disposeBag)
   }
}
