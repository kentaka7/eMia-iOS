//
//  CommentsManager.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift

class CommentsManager: NSObject {

   private var _comments = [CommentItem]()
   private var commnetsObserver = CommentsObserver()
   private let disposeBag = DisposeBag()
   private let wasAdded = Variable<Bool>(false)
   private let wasRemoved = Variable<Bool>(false)
   private let wasUpdated = Variable<Bool>(false)
   
   var isUpdated : Observable<Bool> {
      return Observable.combineLatest(wasAdded.asObservable(), wasRemoved.asObservable(), wasUpdated.asObservable()){ b1, b2, b3 in
         b1 || b2 || b3
      }
   }
   
   var comments: [CommentModel] {
      var comments = [CommentModel]()
      for item in _comments {
         let commentModel = CommentModel(item: item)
         comments.append(commentModel)
      }
      return comments.sorted(by: {$0.created > $1.created})
   }
   
   func startCommentsObserver(for post: PostModel) -> Observable<Bool> {
      DataModel.fetchAllComments(nil, for: post, addComment: { commentItem in
         self.addComment(commentItem)
      }, completion: {
         let observable = self.commnetsObserver.addObserver(for: post)
         _ = observable.add.subscribe({ addedItem in
            self.addComment(addedItem.event.element!)
         }).disposed(by: self.disposeBag)
         _ = observable.update.subscribe({ updatedItem in
            self.editComment(updatedItem.event.element!)
         }).disposed(by: self.disposeBag)
         _ = observable.remove.subscribe({ removedItem in
            self.deleteComment(removedItem.event.element!)
         }).disposed(by: self.disposeBag)
      })
      return isUpdated
   }
}

// MARK: Private methods

extension CommentsManager {
   
   private func addComment(_ item: CommentItem) {
      if let _ = index(of: item) {
         return
      } else if item.id.count > 0 {
         _ = CommentModel.createRealm(model: item)
         _comments.append(item)
         wasAdded.value = true
      }
   }
   
   private func deleteComment(_ item: CommentItem) {
      if let index = index(of: item) {
         _comments.remove(at: index)
         wasRemoved.value = true
      }
   }
   
   private func editComment(_  item: CommentItem) {
      if let index = index(of: item) {
         _comments[index] = item
         _ = CommentModel.createRealm(model: item)
         wasUpdated.value = true
      }
   }
   
   private func index(of item: CommentItem) -> Int? {
      var index = 0
      for comment in _comments {
         if comment == item {
            return index
         }
         index += 1
      }
      return nil
   }
}
