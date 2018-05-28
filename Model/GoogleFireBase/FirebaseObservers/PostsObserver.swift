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

   private var add = Variable<PostItem>(PostItem())
   private var update = Variable<PostItem>(PostItem())
   private var remove = Variable<PostItem>(PostItem())
   
   func addObserver() -> (add: Observable<PostItem>, update: Observable<PostItem>, remove: Observable<PostItem>) {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            self.add.value = item
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            self.remove.value = item
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            let item = PostItem(snapshot)
            self.update.value = item
         }).disposed(by: disposeBag)

      return (add.asObservable(), update.asObservable(), remove.asObservable())
   }
}
