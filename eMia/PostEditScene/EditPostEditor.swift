//
//  EditPostEditor.swift
//  eMia
//
//  Created by Сергей Кротких on 03/09/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView

enum EditPostRows: Int {
   case avatarPhotoAndUserName
   case dependsOnTextViewContent
   case photo
   case staticTextAndSendEmailButton
   static let allValues = [avatarPhotoAndUserName, dependsOnTextViewContent, photo, staticTextAndSendEmailButton]
}

class EditPostEditor: NSObject, EditPostEditorProtocol, EditPostInteractorInputProtocol {
   static private let kMinCommentCellHeight: CGFloat = 45.5
   
   weak var view: EditPostViewProtocol!
   weak var interactor: EditPostInteractor!
   weak var post: PostModel!
   weak var tableView: UITableView!
   weak var tvHeightConstraint: NSLayoutConstraint!
   weak var activityIndicator: NVActivityIndicatorView!

   var viewModel: EditPostViewModel!
   
   private let disposeBag = DisposeBag()
   
   var postBodyTextViewHeight: CGFloat = 0.0
   private var currentCellHeight: CGFloat = EditPostEditor.kMinCommentCellHeight
   private var editingFinished = false
   private var comments: [CommentModel] {
      return interactor.comments
   }

   private var fakeField = FakeFieldController()
   private var keyboardController = KeyboardController()
   
   var observers: [Any] = []

   weak private var commentCell: EditPost4ViewCell?

   deinit {
      unregisterObserver()
      Log()
   }

   func configure() {
      self.registerObserver()
      interactor.configure()
      configureTableView()
      configureKeyboard()
      startEditingFinishedListener()
   }

   func updateView() {
      tableView.reloadData()
   }
   
   private func configureTableView() {
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 140
      tableView.delegate = self
      tableView.dataSource = self
   }

   private func configureKeyboard() {
      keyboardController.configure(with: self.view.view)
   }
   
   private func startEditingFinishedListener() {
      keyboardController.screenPresented.subscribe(onNext: {[weak self] screenPresented in
         self?.editingFinished = screenPresented == false
      }).disposed(by: disposeBag)
   }

}

extension EditPostEditor: UITableViewDataSource, UITableViewDelegate {

   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(tableView: tableView, for: indexPath)
   }
   
   func cell(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
      let row = indexPath.row
      let commentIndex = row - EditPostRows.allValues.count
      if let selector: EditPostRows = EditPostRows(rawValue: row) {
         switch selector {
         case .avatarPhotoAndUserName:
            return tableView.dequeueCell(ofType: EditPost1ViewCell.self)!.then { cell in
               cell.viewModel = viewModel
               viewModel.configure(view: cell, row: selector)
            }
         case .dependsOnTextViewContent:
            return tableView.dequeueCell(ofType: EditPost2ViewCell.self)!.then { cell in
               viewModel.configure(view: cell, row: selector)
            }
         case .photo:
            return tableView.dequeueCell(ofType: EditPost6ViewCell.self)!.then { cell in
               viewModel.configure(view: cell, row: selector)
            }
         case .staticTextAndSendEmailButton:
            return tableView.dequeueCell(ofType: EditPost3ViewCell.self)!.then { cell in
               viewModel.configure(view: cell, row: selector)
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
      self.fakeField.configure(with: self.view.view, anchorView: cell.textView)
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
   
   private func sendComment(_ text: String) {
      activityIndicator.startAnimating()
      interactor.sendComment(text) {
         self.activityIndicator.stopAnimating()
      }
   }

   // TODO: - TRY TO USE https://mkswap.net/m/ios/2015/07/08/uitableviewcells-with-dynamic-height.html
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      let row = indexPath.row
      let commentIndex = row - EditPostRows.allValues.count
      if let selector: EditPostRows = EditPostRows(rawValue: row) {
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
      return EditPostRows.allValues.count + comments.count + 1
   }
}

// MARK: - Interactor output

extension EditPostEditor {
   
   func didUpdateComments() {
      self.tableView.reloadData()
   }
   
   func didAddComment() {
      DispatchQueue.main.async {
         self.tableView.beginUpdates()
         let indexPath = IndexPath(row: EditPostRows.allValues.count + self.comments.count - 1, section: 0)
         self.tableView.insertRows(at: [indexPath], with: .automatic)
         self.tableView.endUpdates()
         self.scrollDownIfNeeded()
      }
   }
}

// MARK: - Enter a new comment handler

extension EditPostEditor {
   
   private func didUpdateTableViewSize() {
      if let commentCell = self.commentCell, commentCell.editViewInActiveState {
         DispatchQueue.main.async { [weak self] in
            self?.fakeField.focus = true
            self?.tableView.reloadData()
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
            self.view.view.setNeedsLayout()
            editingFinished = false
         }
      case .UIKeyboardDidHide:
         if editingFinished {
            tvHeightConstraint.constant = 0.0
            self.view.view.setNeedsLayout()
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
      if let commentCell = self.commentCell,
         commentCell.editViewInActiveState {
         DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let indexPath = IndexPath(row: self.numberOfRows - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
         }
      }
   }
}

// MARK: - AnyObservable protocol implementation
// MARK: Keyboard show/hide observer

extension EditPostEditor: AnyObservable {
   
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
