//
//  RequestsObserver.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class CommentsObserver: NSObject {
   private var _recordRef: DatabaseReference!
   lazy var dbRef = FireBaseManager.firebaseRef.child(CommentItemFields.comments)
   
   private var add = Variable<CommentItem>(CommentItem())
   private var update = Variable<CommentItem>(CommentItem())
   private var remove = Variable<CommentItem>(CommentItem())
   private let disposeBag = DisposeBag()
   
   func addObserver(for post: PostModel) -> (add: Observable<CommentItem>, update: Observable<CommentItem>, remove: Observable<CommentItem>) {
      guard let postId = post.id else {
         return (add.asObservable(), update.asObservable(), remove.asObservable())
      }
      _recordRef = dbRef.child(postId)
      _recordRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self.add.value = item
            }
         }).disposed(by: disposeBag)
      _recordRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self.remove.value = item
            }
         }).disposed(by: disposeBag)
      _recordRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self.update.value = item
            }
         }).disposed(by: disposeBag)
      return (add.asObservable(), update.asObservable(), remove.asObservable())
   }
}
