//
//  PostsObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class PostsObserver: NSObject {
   lazy var dbRef = FireBaseManager.firebaseRef.child(PostItemFields.posts)
   private let disposeBag = DisposeBag()

   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            PostModel.addPost(item)
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            PostModel.deletePost(item)
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            PostModel.editPost(item)
         }).disposed(by: disposeBag)
   }
}
