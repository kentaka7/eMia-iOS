//
//  PostsObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class PostsObserver: NSObject {
   
   fileprivate var _refHandleForAdd: DatabaseHandle?
   fileprivate var _refHandleForRemove: DatabaseHandle?
   fileprivate var _refHandleForChange: DatabaseHandle?

   lazy var dbRef = FireBaseManager.firebaseRef.child(PostItemFields.posts)
   private let disposeBag = DisposeBag()
   
   func addObserver() {
      dbRef
         .rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            ModelData.addPostsListener(item)
         }).disposed(by: disposeBag)
      
      dbRef
         .rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            ModelData.deletePostsListener(item)
         }).disposed(by: disposeBag)
      
      dbRef
         .rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            ModelData.editPostsListener(item)
         }).disposed(by: disposeBag)
   }
   
   private func oldObserver() {
      
      removeObserver()
      
      // Listen for new posts in the Firebase database
      _refHandleForAdd = dbRef.observe(.childAdded, with: { (snapshot) -> Void in
         let item = PostItem(snapshot)
         ModelData.addPostsListener(item)
      })
      // Listen for deleted posts in the Firebase database
      _refHandleForRemove = dbRef.observe(.childRemoved, with: { (snapshot) -> Void in
         let item = PostItem(snapshot)
         ModelData.deletePostsListener(item)
      })
      // Listen for changed posts in the Firebase database
      _refHandleForChange = dbRef.observe(.childChanged, with: {(snapshot) -> Void in
         let item = PostItem(snapshot)
         ModelData.editPostsListener(item)
      })
   }
   
   func removeObserver() {
      if let _ = _refHandleForAdd, let _ = _refHandleForRemove, let _ = _refHandleForChange {
         FireBaseManager.firebaseRef.child(PostItemFields.posts).removeObserver(withHandle: _refHandleForAdd!)
         FireBaseManager.firebaseRef.child(PostItemFields.posts).removeObserver(withHandle: _refHandleForRemove!)
         FireBaseManager.firebaseRef.child(PostItemFields.posts).removeObserver(withHandle: _refHandleForChange!)
      }
   }
}
