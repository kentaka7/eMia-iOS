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
   private var mNewCommentObservable = BehaviorSubject<Bool>(value: false)

   var comments: [CommentModel] {
      guard let post = self.post else {
         return []
      }
      return CommentModel.comments.filter { $0.postid == post.id }
   }
   
   func startCommentsObserver(for post: PostModel) -> Observable<Bool> {
      self.post = post
      _ = CommentModel.rxNewCommentObserved.subscribe(onNext: { [weak self] newComment in
         if let post = self?.post, newComment?.postid == post.id {
            self?.mNewCommentObservable.onNext(true)
         }
      })
      return mNewCommentObservable.asObservable()
   }
}
