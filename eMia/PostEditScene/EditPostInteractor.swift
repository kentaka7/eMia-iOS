//
//  EditPostInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 22/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RealmSwift

class EditPostInteractor: EditPostInteractorProtocol {
   
   weak var presenter: EditPostPresenterProtocol!
   weak var post: PostModel!
   
   private var commentResults: Results<CommentModel>?
   private var token: NotificationToken?
   var comments = [CommentModel]()
   
   deinit {
      token?.invalidate()
      Log()
   }
   
   func configure(post: PostModel) {
      self.post = post
      startExternalCommentsListener()
   }
   
   private func startExternalCommentsListener() {
      guard let postid = self.post.id else {
         return
      }
      let realm = try? Realm()
      commentResults = realm?.objects(CommentModel.self).filter("postid = '\(postid)'") // Auto-Updating Results
      token = commentResults?.observe({[weak self] change in
         guard let `self` = self else {
            return
         }
         switch change {
         case .initial:
            if let result = self.commentResults?.sorted(by: { (comment1, comment2) -> Bool in
               return comment1.created < comment2.created
            }) {
               self.comments = result
            } else {
               self.comments = [CommentModel]()
            }
            self.presenter.didUpdateComments()
         case .error(let error):
            fatalError("\(error)")
         case .update(_, _, let insertions, _):
            if insertions.count == 0 {
               return
            }
            if let result = self.commentResults?.sorted(by: { (comment1, comment2) -> Bool in
               return comment1.created < comment2.created
            }) {
               if let newComment = result.last {
                  self.comments.append(newComment)
                  self.presenter.didAddComment()
               }
            }
         }
      })
   }
   
   func sendComment(_ text: String, completion: @escaping () -> Void) {
      guard let currentUser = gUsersManager.currentUser else {
         completion()
         return
      }
      let newComment = CommentModel(uid: currentUser.userId, author: currentUser.name, text: text, postid: post.id!)
      newComment.synchronize { success in
         completion()
      }
   }
}
