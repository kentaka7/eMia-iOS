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

class CommentsObserver: FireBaseListener {
   lazy var dbRef = gDataBaseRef.child(CommentItemFields.comments)
   private let disposeBag = DisposeBag()
   private let localDB = LocalBaseController()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem(snapshot) {
               self.localDB.addComment(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem(snapshot) {
               self.localDB.deleteComment(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem(snapshot) {
               self.localDB.editComment(item)
            }
         }).disposed(by: disposeBag)
   }
}
