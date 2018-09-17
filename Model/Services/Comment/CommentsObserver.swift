//
//  CommentsObserver.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class CommentsObserver: FirebaseListener {
   lazy var dbRef = gDataBaseRef.child(CommentItem.TableName)
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
