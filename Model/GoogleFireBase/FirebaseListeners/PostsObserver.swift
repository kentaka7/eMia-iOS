//
//  PostsObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class PostsObserver: FireBaseListener {
   lazy var dbRef = gDataBaseRef.child(PostItem.TableName)
   private let disposeBag = DisposeBag()
   private let localDB = LocalBaseController()

   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = PostItem(snapshot) {
               self.localDB.addPost(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = PostItem(snapshot) {
               self.localDB.deletePost(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = PostItem(snapshot) {
               self.localDB.editPost(item)
            }
         }).disposed(by: disposeBag)
   }
}
