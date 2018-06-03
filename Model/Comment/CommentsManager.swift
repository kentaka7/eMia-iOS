//
//  CommentsManager.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RxSwift

class CommentsManager: NSObject {

   private var post: PostModel?
   
   var comments: [CommentModel] {
      guard let post = self.post else {
         return []
      }
      let comments = DataModel.comments
      var postComments = [CommentModel]()
      comments.forEach { model in
         if model.postid == post.id {
            postComments.append(model)
         }
      }
      return postComments
   }

   private var mNewCommentObservable = Variable<Bool>(false)
   
   func startCommentsObserver(for post: PostModel) -> Observable<Bool> {
      self.post = post
      _ = DataModel.rxNewCommentObserved.asObservable().subscribe({ [weak self] newComment in
         if let newComment = newComment.event.element, let post = self?.post, newComment?.postid == post.id {
            self?.mNewCommentObservable.value = true
         }
      })
      return mNewCommentObservable.asObservable()
   }
}
