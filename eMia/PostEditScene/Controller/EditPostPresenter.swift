//
//  EditPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import NVActivityIndicatorView

class EditPostPresenter: NSObject, EditPostPresenting {
   static private let kMinCommentCellHeight: CGFloat = 58.0
   
   enum Rows: Int {
      case avatarPhotoAndUserName
      case dependsOnTextViewContent
      case photo
      case staticTextAndSendEmailButton
      case enterCommentTextAndSendButton
      static let allValues = [avatarPhotoAndUserName, dependsOnTextViewContent, photo, staticTextAndSendEmailButton, enterCommentTextAndSendButton]
   }
   
   private var commentCell: EditPost4ViewCell!
   private var postBodyTextViewHeight: CGFloat = 0.0
   private var currentCelHeight: CGFloat = EditPostPresenter.kMinCommentCellHeight
   private var commentsManager = CommentsManager()
   private var comments: [CommentModel]!
   private var needUpdateView: Bool = true
   private let disposeBag = DisposeBag()
   
   weak var activityIndicator: NVActivityIndicatorView!
   var post: PostModel!
   weak var tableView: UITableView?
   
   func configure() {
      startCommentsListener()
   }
   
   private func startCommentsListener() {
      _ = commentsManager.startCommentsObserver(for: post).subscribe({ [weak self] isUpdated in
         if let updated = isUpdated.event.element, updated == true {
            self?.didUpdateCommentsData()
         }
      }).disposed(by: disposeBag)
   }
   
   func update() {
      downloadComments()
   }
   
   var title: String {
      return post.title
   }
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      guard let tableView = self.tableView else {
         return UITableViewCell()
      }
      
      if let selector: Rows = Rows(rawValue: indexPath.row) {
         switch selector {
         case .avatarPhotoAndUserName:
            return tableView.dequeueCell(ofType: EditPost1ViewCell.self)!.then { cell in
               _ = cell.configureView(for: post)
            }
         case .dependsOnTextViewContent:
            return tableView.dequeueCell(ofType: EditPost2ViewCell.self)!.then { cell in
               postBodyTextViewHeight = cell.configureView(for: post)
            }
         case .photo:
            return tableView.dequeueCell(ofType: EditPost6ViewCell.self)!.then { cell in
               _ = cell.configureView(for: post)
            }
         case .staticTextAndSendEmailButton:
            return tableView.dequeueCell(ofType: EditPost3ViewCell.self)!.then { cell in
               _ = cell.configureView(for: post)
            }
         case .enterCommentTextAndSendButton:
            return tableView.dequeueCell(ofType: EditPost4ViewCell.self)!.then { cell in
               self.commentCell = cell
               _ = self.commentCell.configureView(for: post)
               self.commentCell.post = post
               self.commentCell.activityIndicator = activityIndicator
               self.commentCell.didChangeHeight = { newCellHeight in
                  if newCellHeight != self.currentCelHeight {
                     self.currentCelHeight = newCellHeight
                     self.updateView(tableView: self.tableView!)
                  }
               }
               self.commentCell.didEnterNewComment = {
                  self.needUpdateView = false
               }
            }
         }
      } else {
         if comments.count > 0 {
            return tableView.dequeueCell(ofType: EditPost5ViewCell.self)!.then { cell in
               _ = cell.configureView(for: post)
               let comment = comments[indexPath.row - Rows.allValues.count]
               cell.configureView(for: comment)
            }
         } else {
            let cell0 = UITableViewCell()
            return cell0
         }
      }
   }
   
   // TODO: - TRY TO USE https://mkswap.net/m/ios/2015/07/08/uitableviewcells-with-dynamic-height.html
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      if let selector: Rows = Rows(rawValue: indexPath.row) {
         switch selector {
         case .avatarPhotoAndUserName:
            return 70.0
         case .dependsOnTextViewContent:
            return postBodyTextViewHeight
         case .photo:
            return 300.0
         case .staticTextAndSendEmailButton:
            return 135.0
         case .enterCommentTextAndSendButton:
            return currentCelHeight
         }
      } else {
         if comments.count > 0 {
            return -1.0
         } else {
            return 0.0
         }
      }
   }
   
   var numberOfRows: Int {
      return Rows.allValues.count + comments.count
   }
   
   private func updateView(tableView: UITableView) {
      tableView.reloadData()
      if self.needUpdateView == false {
         self.needUpdateView = true
         return
      }
      runAfterDelay(0.3) {
         _ = self.commentCell.commentTextView.becomeFirstResponder()
      }
   }
}

// MARK: - CommentsUpdatable

extension EditPostPresenter: CommentsUpdatable {
   
   fileprivate func downloadComments() {
      guard let tableView = self.tableView else {
         return
      }
      comments = commentsManager.comments
      tableView.reloadData()
   }
   
   func didUpdateCommentsData() {
      downloadComments()
   }
}
