//
//  RequestsObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class CommentsObserver: NSObject {
   fileprivate var _refHandleForAdd: DatabaseHandle?
   fileprivate var _refHandleForRemove: DatabaseHandle?
   fileprivate var _refHandleForChange: DatabaseHandle?

   fileprivate var _recordRef: DatabaseReference!
   fileprivate var _delegate: CommentsListening!

   lazy var dbRef = FireBaseManager.firebaseRef.child(CommentItemFields.comments)
   
   private let disposeBag = DisposeBag()
   
   func addObserver(for post: PostModel, delegate: CommentsListening) {
      
      guard let postId = post.id else {
         return
      }
      
      _delegate = delegate
      _recordRef = dbRef.child(postId)
      
      _recordRef
         .rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self._delegate.addCommentsListener(item)
            }
         }).disposed(by: disposeBag)
      
      _recordRef
         .rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self._delegate.deleteCommentsListener(item)
            }
         }).disposed(by: disposeBag)
      
      _recordRef
         .rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = CommentItem.decodeSnapshot(snapshot) {
               self._delegate.editCommentsListener(item)
            }
         }).disposed(by: disposeBag)
   }
   
   private func oldObserver(for post: PostModel, delegate: CommentsListening) {

      removeObserver()
      
      guard let postId = post.id else {
         return
      }

      _delegate = delegate
      _recordRef = dbRef.child(postId)
      
      // Listen for new users in the Firebase database
      _refHandleForAdd = _recordRef.observe(.childAdded, with: { (snapshot) -> Void in
         if let item = CommentItem.decodeSnapshot(snapshot) {
            self._delegate.addCommentsListener(item)
         }
      })
      // Listen for deleted users in the Firebase database
      _refHandleForRemove = _recordRef.observe(.childRemoved, with: { (snapshot) -> Void in
         if let item = CommentItem.decodeSnapshot(snapshot) {
            self._delegate.deleteCommentsListener(item)
         }
      })
      // Listen for changed users in the Firebase database
      _refHandleForChange = _recordRef.observe(.childChanged, with: {(snapshot) -> Void in
         if let item = CommentItem.decodeSnapshot(snapshot) {
            self._delegate.editCommentsListener(item)
         }
      })
   }
   
   func removeObserver() {
      if let _ = _refHandleForAdd, let _ = _refHandleForRemove, let _ = _refHandleForChange {
         _recordRef.removeObserver(withHandle: _refHandleForAdd!)
         _recordRef.removeObserver(withHandle: _refHandleForRemove!)
         _recordRef.removeObserver(withHandle: _refHandleForChange!)
      }
   }
}
