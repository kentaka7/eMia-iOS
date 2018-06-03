//
//  CommentsObserver.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class CommentsObserver: NSObject {
   lazy var dbRef = FireBaseManager.firebaseRef.child(CommentItemFields.comments)
   private var add = Variable<CommentItem>(CommentItem())
   private var update = Variable<CommentItem>(CommentItem())
   private var remove = Variable<CommentItem>(CommentItem())
   private let disposeBag = DisposeBag()
   
   func addObserver() -> (add: Observable<CommentItem>, update: Observable<CommentItem>, remove: Observable<CommentItem>) {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self.add.value = item
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self.remove.value = item
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self.update.value = item
            }
         }).disposed(by: disposeBag)
      return (add.asObservable(), update.asObservable(), remove.asObservable())
   }
}
