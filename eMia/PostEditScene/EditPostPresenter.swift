//
//  EditPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import NVActivityIndicatorView

class EditPostPresenter: NSObject, EditPostPresenterProtocol {
   static private let kMinCommentCellHeight: CGFloat = 45.5
   
   weak var view: EditPostViewProtocol!
   var interactor: EditPostInteractor!
   var router: EditPostRouterProtocol!
   
   var fakeField: FakeFieldController!
   var keyboardController: KeyboardController!

   enum Rows: Int {
      case avatarPhotoAndUserName
      case dependsOnTextViewContent
      case photo
      case staticTextAndSendEmailButton
      static let allValues = [avatarPhotoAndUserName, dependsOnTextViewContent, photo, staticTextAndSendEmailButton]
   }

   private var post: PostModel {
      return view.post
   }
   
   private var tableView: UITableView {
      return view.tableView
   }

   private var activityIndicator: NVActivityIndicatorView {
      return view.activityIndicator
   }

   private var tvHeightConstraint: NSLayoutConstraint {
      return view.bottomTableViewConstraint
   }
   
   private var backBarButtonItem: UIBarButtonItem {
      return view.backBarButtonItem
   }
   
   private let disposeBag = DisposeBag()
   
   weak private var commentCell: EditPost4ViewCell?
   
   private var postBodyTextViewHeight: CGFloat = 0.0
   private var currentCellHeight: CGFloat = EditPostPresenter.kMinCommentCellHeight

   private var comments: [CommentModel] {
      return self.interactor.comments
   }
   
   private var editingFinished = false
   
   var observers: [Any] = []
   
   deinit {
      unregisterObserver()
      Log()
   }
   
   func configure() {
      configureKeyboard()
      configureTableView()
      configureBackButton()
      registerObserver()
      startEditingFinishedListener()
      interactor.configure(post: self.post)
   }
   
   private func configureKeyboard() {
      guard let keyboardController = self.keyboardController else {
         return
      }
      keyboardController.configure(with: self.view.view)
   }
   
   private func startEditingFinishedListener() {
      keyboardController!.screenPresented.subscribe(onNext: {[weak self] screenPresented in
         self?.editingFinished = screenPresented == false
      }).disposed(by: disposeBag)
   }
   
   func updateView() {
      tableView.reloadData()
   }
   
   var title: String {
      return post.title
   }
   
   private func configureBackButton() {
      backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.router.closeCurrentViewController()
      }).disposed(by: disposeBag)
   }
}

// MARK: - Interactor output

extension EditPostPresenter {

   func didUpdateComments() {
      self.tableView.reloadData()
   }
   
   func didAddComment() {
      DispatchQueue.main.async {
         self.tableView.beginUpdates()
         let indexPath = IndexPath(row: Rows.allValues.count + self.comments.count - 1, section: 0)
         self.tableView.insertRows(at: [indexPath], with: .automatic)
         self.tableView.endUpdates()
         self.scrollDownIfNeeded()
      }
   }
}

// MARK: - TableView

extension EditPostPresenter: UITableViewDataSource, UITableViewDelegate {

   private func configureTableView() {
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 140
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(for: indexPath)
   }

   func cell(for indexPath: IndexPath) -> UITableViewCell {
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
      self.fakeField?.configure(with: self.view.view, anchorView: cell.textView)
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
      activityIndicator.startAnimating()
      interactor.sendComment(text) {
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
      if let commentCell = self.commentCell, commentCell.editViewInActiveState {
         DispatchQueue.main.async { [weak self] in
            self?.fakeField?.focus = true
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
