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
   weak var input: EditPostInteractorInputProtocol!
   
   private var commentResults: Results<CommentModel>?
   private var token: NotificationToken?
   var comments = [CommentModel]()
   
   deinit {
      token?.invalidate()
      Log()
   }
   
   func configure() {
      startListeningToComments()
   }
   
   func updateView() {
      input.updateView()
   }
   
   func didUpdateComments() {
      input.didUpdateComments()
   }

   func didAddComment() {
      input.didAddComment()
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

// MARK: - Private methods

extension EditPostInteractor {
   
   private func startListeningToComments() {
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
            self.didAllDataReceive()
         case .error(let error):
            fatalError("\(error)")
         case .update(_, _, let insertions, _):
            if insertions.count == 0 {
               return
            }
            self.didDataUpdate()
         }
      })
   }
   
   private func didAllDataReceive() {
      if let result = self.commentResults?.sorted(by: { (comment1, comment2) -> Bool in
         return comment1.created < comment2.created
      }) {
         self.comments = result
      } else {
         self.comments = [CommentModel]()
      }
      self.presenter.didUpdateComments()
   }
   
   private func didDataUpdate() {
      if let result = self.commentResults?.sorted(by: { (comment1, comment2) -> Bool in
         return comment1.created < comment2.created
      }) {
         if let newComment = result.last {
            self.comments.append(newComment)
            self.presenter.didAddComment()
         }
      }
   }
}
