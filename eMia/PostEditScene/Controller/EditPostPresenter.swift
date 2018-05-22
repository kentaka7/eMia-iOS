//
//  EditPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol CommentsUpdatable {
   func didUpdateCommentsData()
}

class EditPostPresenter: NSObject {
   static private let kMinCommentCellHeight: CGFloat = 58.0

   enum Rows: Int {
      case AvatarPhotoAndUserName
      case DependsOnTextViewContent
      case Photo
      case StaticTextAndSendEmailButton
      case EnterCommentTextAndSendButton
      static let allValues = [AvatarPhotoAndUserName, DependsOnTextViewContent, Photo, StaticTextAndSendEmailButton, EnterCommentTextAndSendButton]
   }

   internal struct CellName {
      static let editPost1ViewCell = "EditPost1ViewCell"
      static let editPost2ViewCell = "EditPost2ViewCell"
      static let editPost3ViewCell = "EditPost3ViewCell"
      static let editPost4ViewCell = "EditPost4ViewCell"
      static let editPost5ViewCell = "EditPost5ViewCell"
      static let editPost6ViewCell = "EditPost6ViewCell"
   }

   private var commentCell: EditPost4ViewCell!
   private var postBodyTextViewHeight: CGFloat = 0.0
   private var currentCelHeight: CGFloat = EditPostPresenter.kMinCommentCellHeight
   private var commentsManager = CommentsManager()
   private var comments: [CommentModel]!
   private var needUpdateView: Bool = true
   
   weak var activityIndicator: NVActivityIndicatorView!
   var post: PostModel!
   var tableView: UITableView!
   
   func configure() {
      commentsManager.startCommentsObserver(for: post, delegate: self)
   }
   
   func update() {
      downloadComments()
   }
   
   func tableView(_ tableView: UITableView, cellFor indexPath: IndexPath) -> UITableViewCell {
      if let selector: Rows = Rows(rawValue: indexPath.row) {
         switch selector {
         case .AvatarPhotoAndUserName:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: CellName.editPost1ViewCell) as! EditPost1ViewCell
            let _ = cell1.configureView(for: post)
            return cell1
         case .DependsOnTextViewContent:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: CellName.editPost2ViewCell) as! EditPost2ViewCell
            postBodyTextViewHeight = cell2.configureView(for: post)
            return cell2
         case .Photo:
            let cell6 = tableView.dequeueReusableCell(withIdentifier: CellName.editPost6ViewCell) as! EditPost6ViewCell
            let _ = cell6.configureView(for: post)
            return cell6
         case .StaticTextAndSendEmailButton:
            let cell3 = tableView.dequeueReusableCell(withIdentifier: CellName.editPost3ViewCell) as! EditPost3ViewCell
            let _ = cell3.configureView(for: post)
            return cell3
         case .EnterCommentTextAndSendButton:
            commentCell = tableView.dequeueReusableCell(withIdentifier: CellName.editPost4ViewCell) as! EditPost4ViewCell
            let _ = commentCell.configureView(for: post)
            commentCell.post = post
            commentCell.activityIndicator = activityIndicator
            commentCell.didChangeHeight = { newCellHeight in
               if newCellHeight != self.currentCelHeight {
                  self.currentCelHeight = newCellHeight
                  self.updateView(tableView: tableView)
               }
            }
            commentCell.didEnterNewComment = {
               self.needUpdateView = false
            }
            return commentCell
         }
      } else {
         if comments.count > 0 {
            let cell5 = tableView.dequeueReusableCell(withIdentifier: CellName.editPost5ViewCell) as! EditPost5ViewCell
            let _ = cell5.configureView(for: post)
            let comment = comments[indexPath.row - Rows.allValues.count]
            cell5.configureView(for: comment)
            return cell5
         } else {
            let cell0 = UITableViewCell()
            return cell0
         }
      }
   }

   // TODO: - TRY TO USE https://mkswap.net/m/ios/2015/07/08/uitableviewcells-with-dynamic-height.html

   func tableView(_ tableView: UITableView, heightCellFor indexPath: IndexPath) -> CGFloat {
      if let selector: Rows = Rows(rawValue: indexPath.row) {
         switch selector {
         case .AvatarPhotoAndUserName:
            return 70.0
         case .DependsOnTextViewContent:
            return postBodyTextViewHeight
         case .Photo:
            return 300.0
         case .StaticTextAndSendEmailButton:
            return 135.0
         case .EnterCommentTextAndSendButton:
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
         let _ = self.commentCell.commentTextView.becomeFirstResponder()
      }
   }
}

// MARK: - CommentsUpdatable

extension EditPostPresenter: CommentsUpdatable {
   
   fileprivate func downloadComments() {
      comments = commentsManager.comments
      tableView.reloadData()
   }
   
   func didUpdateCommentsData() {
      downloadComments()
   }
}
