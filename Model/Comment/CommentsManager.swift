//
//  CommentsManager.swift
//  eMia
//

import UIKit
import RxSwift

class CommentsManager: NSObject {

   private var _comments = [CommentItem]()
   private var commnetsObserver = CommentsObserver()
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
         let commentModel = CommentModel(postItem: item)
         comments.append(commentModel)
      }
      return comments.sorted(by: {$0.created > $1.created})
   }
   
   func startCommentsObserver(for post: PostModel) -> Observable<Bool> {
      ModelData.fetchAllComments(nil, for: post, addComment: { commentItem in
         self.addCommentsListener(commentItem)
      }, completion: {
         let observable = self.commnetsObserver.addObserver(for: post)
         _ = observable.add.subscribe({ addedItem in
            self.addCommentsListener(addedItem.event.element!)
         })
         _ = observable.update.subscribe({ updatedItem in
            self.editCommentsListener(updatedItem.event.element!)
         })
         _ = observable.remove.subscribe({ removedItem in
            self.deleteCommentsListener(removedItem.event.element!)
         })
      })
      return isUpdated
   }
}

extension CommentsManager {
   
   private func addCommentsListener(_ item: CommentItem) {
      if let _ = index(of: item) {
      } else {
         _comments.append(item)
         wasAdded.value = true
      }
   }
   
   private func deleteCommentsListener(_ item: CommentItem) {
      if let index = index(of: item) {
         _comments.remove(at: index)
         wasRemoved.value = true
      }
   }
   
   private func editCommentsListener(_  item: CommentItem) {
      if let index = index(of: item) {
         _comments[index] = item
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
