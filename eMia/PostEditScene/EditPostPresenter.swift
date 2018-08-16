//
//  EditPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import NVActivityIndicatorView

class EditPostPresenter: NSObject, EditPostPresenting {
   static private let kMinCommentCellHeight: CGFloat = 45.5
   
   enum Rows: Int {
      case avatarPhotoAndUserName
      case dependsOnTextViewContent
      case photo
      case staticTextAndSendEmailButton
      static let allValues = [avatarPhotoAndUserName, dependsOnTextViewContent, photo, staticTextAndSendEmailButton]
   }
   
   weak private var commentCell: EditPost4ViewCell?
   private var postBodyTextViewHeight: CGFloat = 0.0
   private var currentCellHeight: CGFloat = EditPostPresenter.kMinCommentCellHeight
   private var comments = [CommentModel]()
   private let disposeBag = DisposeBag()
   private let commentsManager = CommentsManager()
   private var commentResults: Results<CommentModel>?
   
   weak var activityIndicator: NVActivityIndicatorView!
   weak var post: PostModel!
   weak var tableView: UITableView?
   weak var tvHeightConstraint: NSLayoutConstraint!
   weak var view: UIView! {
      didSet {
         guard let keyboardController = self.keyboardController else {
            return
         }
         keyboardController.configure(with: self.view)
      }
   }
   
   var fakeField: FakeFieldController?
   var keyboardController: KeyboardController?
   private var editingFinished = false
   private var token: NotificationToken?
   
   var observers: [Any] = []
   
   deinit {
      token?.invalidate()
      unregisterObserver()
      Log()
   }
   
   func configure() {
      registerObserver()
      startExternalCommentsListener()
      startEditingFinishedListener()
   }
   
   private func startEditingFinishedListener() {
      keyboardController!.screenPresented.subscribe(onNext: {[weak self] screenPresented in
         self?.editingFinished = screenPresented == false
      }).disposed(by: disposeBag)
   }
   
   func updateView() {
      tableView?.reloadData()
   }
   
   var title: String {
      return post.title
   }
   
}

// MARK: - Comments data source

extension EditPostPresenter {

   private func startExternalCommentsListener() {
      guard let postid = self.post?.id else {
         return
      }
      let realm = try? Realm()
      commentResults = realm?.objects(CommentModel.self).filter("postid = '\(postid)'") // Auto-Updating Results
      token = commentResults?.observe({[weak self] change in
         guard let `self` = self, let tableView = self.tableView else {
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
            self.tableView?.reloadData()
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
                  DispatchQueue.main.async {
                     self.comments.append(newComment)
                     tableView.beginUpdates()
                     let indexPath = IndexPath(row: Rows.allValues.count + self.comments.count - 1, section: 0)
                     tableView.insertRows(at: [indexPath], with: .automatic)
                     tableView.endUpdates()
                     self.scrollDownIfNeeded()
                  }
               }
            }
         }
      })
   }
}

// MARK: - TableView delegate model

extension EditPostPresenter {

   func cell(for indexPath: IndexPath) -> UITableViewCell {
      guard let tableView = self.tableView else {
         return UITableViewCell()
      }
      let row = indexPath.row
      let commentIndex = row - Rows.allValues.count
      if let selector: Rows = Rows(rawValue: row) {
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
         }
      } else if commentIndex >= 0 && commentIndex < comments.count {
         return tableView.dequeueCell(ofType: EditPost5ViewCell.self)!.then { cell in
            _ = cell.configureView(for: post)
            let comment = comments[commentIndex]
            cell.configureView(for: comment)
         }
      } else {
         if self.commentCell == nil {
            return tableView.dequeueCell(ofType: EditPost4ViewCell.self)!.then { cell in
               self.commentCell = cell
               self.configureCommentCell(cell)
            }
         } else {
            return self.commentCell!
         }
      }
   }
   
   private func configureCommentCell(_ cell: EditPost4ViewCell) {
      self.fakeField?.configure(with: self.view, anchorView: cell.textView)
      cell.currentCellHeigt.subscribe(onNext: {[weak self] (newCellHeight) in
         guard let `self` = self else { return }
         if newCellHeight != self.currentCellHeight {
            self.currentCellHeight = newCellHeight
            self.didUpdateTableViewSize()
         }
      }).disposed(by: disposeBag)
      cell.commentText.subscribe({ [weak self] (text) in
         guard let comment = text.element else { return }
         guard let `self` = self else { return }
         self.editingFinished = true
         self.sendComment(comment)
      }).disposed(by: disposeBag)
   }
   
   // TODO: - TRY TO USE https://mkswap.net/m/ios/2015/07/08/uitableviewcells-with-dynamic-height.html
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      let row = indexPath.row
      let commentIndex = row - Rows.allValues.count
      if let selector: Rows = Rows(rawValue: row) {
         switch selector {
         case .avatarPhotoAndUserName:
            return 70.0
         case .dependsOnTextViewContent:
            return postBodyTextViewHeight
         case .photo:
            return 300.0
         case .staticTextAndSendEmailButton:
            return 135.0
         }
      } else if commentIndex >= 0 && commentIndex < comments.count {
         return -1.0
      } else {
         return currentCellHeight
      }
   }
   
   var numberOfRows: Int {
      return Rows.allValues.count + comments.count + 1
   }
}

// MARK: - Save new comments

extension EditPostPresenter {
   
   private func sendComment(_ text: String) {
      guard let currentUser = gUsersManager.currentUser else {
         return
      }
      activityIndicator.startAnimating()
      let newComment = CommentModel(uid: currentUser.userId, author: currentUser.name, text: text, postid: post.id!)
      newComment.synchronize { success in
         self.activityIndicator.stopAnimating()
      }
   }
}

// MARK: - AnyObservable protocol implementation
// MARK: Keyboard show/hide observer

extension EditPostPresenter: AnyObservable {
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      observers.append(
         _ = center.addObserver(forName: .UIKeyboardDidShow, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.tableViewFitSize(kbNotification: notification)
         }
      )
      observers.append(
         _ = center.addObserver(forName: .UIKeyboardDidHide, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.tableViewFitSize(kbNotification: notification)
         }
      )
   }
}

// MARK: - Enter a new comment handler

extension EditPostPresenter {
   
   private func didUpdateTableViewSize() {
      guard let tableView = self.tableView else {
         return
      }
      if let commentCell = self.commentCell, commentCell.editViewInActiveState {
         DispatchQueue.main.async { [weak self] in
            self?.fakeField?.focus = true
            tableView.reloadData()
         }
         runAfterDelay(0.3) {
            _ = commentCell.textView.becomeFirstResponder()
         }
      } else {
         tableView.reloadData()
      }
   }
   
   private func tableViewFitSize(kbNotification: Notification) {
      switch kbNotification.name {
      case .UIKeyboardDidShow:
         if let height = self.keyboardHeight(kbNotification: kbNotification) {
            tvHeightConstraint.constant = height
            view.setNeedsLayout()
            editingFinished = false
         }
      case .UIKeyboardDidHide:
         if editingFinished {
            tvHeightConstraint.constant = 0.0
            view.setNeedsLayout()
         }
      default:
         break
      }
   }
   
   private func keyboardHeight(kbNotification: Notification) -> CGFloat? {
      guard let info = kbNotification.userInfo  else {
         return nil
      }
      
      #if swift(>=4.2)
      let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
      #else
      let frameEndUserInfoKey = UIKeyboardFrameEndUserInfoKey
      #endif
      
      if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
         return kbFrame.height
      } else {
         return nil
      }
   }
   
   private func scrollDownIfNeeded() {
      if let tableView = self.tableView,
         let commentCell = self.commentCell,
         commentCell.editViewInActiveState {
         DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let indexPath = IndexPath(row: self.numberOfRows - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
         }
      }
   }
}
