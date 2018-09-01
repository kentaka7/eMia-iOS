//
//  NewPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NewPostPresenter: NSObject, NewPostPresenterProtocol {

   var interactor: NewPostInteractorProtocol!
   var router: NewPostRouterProtocol!

   weak var view: NewPostViewProtocol!

   private var tableView: UITableView? {
      return view.tableView
   }

   private var fakeTextField: UITextField? {
      return view.fakeTextField
   }
   
   private var viewController: UIViewController? {
      return view.viewController
   }
   
   private var saveButton: UIButton! {
      return view.saveButton
   }
   
   private var backBarButtonItem: UIBarButtonItem! {
      return view.backBarButtonItem
   }

   private let disposeBag = DisposeBag()
   
   enum Rows: Int {
      case title
      case body
      case photo
      static let allValues = [title, body, photo]
   }

   private var textBodyHeight: CGFloat = 78.0
   
   private var titleCell: NewPost1ViewCell!
   private var bodyCell: NewPost2ViewCell!
   private var photoCell: NewPost3ViewCell!
   
   var title: String {
      return "\(AppConstants.ApplicationName) - My new post".localized
   }
   
   deinit {
      Log()
   }
   
   func configureView() {
      configureTableView()
      setUpDoneButton()
      setUpBackButton()
   }
   
   private func setUpDoneButton() {
      saveButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.save {
            self.router.closeScene()
         }
      }).disposed(by: disposeBag)
   }
   
   private func setUpBackButton() {
      backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.router.closeScene()
      }).disposed(by: disposeBag)
   }
}

// MARK: - Create new Post

extension NewPostPresenter {
   
   func save(_ completed: @escaping () -> Void) {
      let title = titleCell.titlePostText
      if title.isEmpty {
         titleCell.invalidValue()
         return
      }
      guard let image = photoCell.photoImage else {
         Alert.default.showOk("", message: "Please add photo to the post!".localized)
         return
      }
      let bodyText = bodyCell.postBodyText
      interactor.saveNewPost(title: title, image: image, body: bodyText, completed)
   }
}

// MARK: - TableView delegate protocol implementation

extension NewPostPresenter: UITableViewDelegate, UITableViewDataSource {

   private func configureTableView() {
      tableView!.rowHeight = UITableViewAutomaticDimension
      tableView!.estimatedRowHeight = 140
      tableView!.delegate = self
      tableView!.dataSource = self
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
      guard let tableView = self.tableView else {
         return UITableViewCell()
      }
      
      if let selector = Rows(rawValue: indexPath.row) {
         switch selector {
         case .title:
            return tableView.dequeueCell(ofType: NewPost1ViewCell.self)!.then { cell in
               self.titleCell = cell
            }
         case .body:
            return tableView.dequeueCell(ofType: NewPost2ViewCell.self)!.then { cell in
               self.bodyCell = cell
               bodyCell.didChangeHeight = { height in
                  if height > self.textBodyHeight {
                     self.textBodyHeight = height
                     // It prevents hiding keyboard
                     self.fakeTextField?.becomeFirstResponder()
                     self.tableView?.reloadData()
                     runAfterDelay(0.2) {
                        // return back focus on the text view
                        _ = self.bodyCell.postBodyTextView.becomeFirstResponder()
                     }
                  }
               }
            }
         case .photo:
            return tableView.dequeueCell(ofType: NewPost3ViewCell.self)!.then { cell in
               self.photoCell = cell
               self.photoCell.viewController = viewController
            }
         }
      } else {
         let cell = UITableViewCell()
         return cell
      }
   }
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      if let selector = Rows(rawValue: indexPath.row) {
         switch selector {
         case .title:
            return 59.0
         case .body:
            return textBodyHeight
         case .photo:
            return 364.0
         }
      } else {
         return 0.0
      }
   }
   
   var numberOfRows: Int {
      return Rows.allValues.count
   }
}
