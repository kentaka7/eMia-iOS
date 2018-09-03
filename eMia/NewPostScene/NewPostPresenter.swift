//
//  NewPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostPresenter: NSObject, NewPostPresenterProtocol {

   var interactor: NewPostInteractorProtocol!
   var router: NewPostRouterProtocol!

   private var editor: NewPostEditor!
   
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
   
   var title: String {
      return "\(AppConstants.ApplicationName) - My new post".localized
   }
   
   deinit {
      Log()
   }
   
   func configureView() {
      configureEditor()
   }

   private func configureEditor() {
      editor = NewPostEditor(tableView: tableView!, fakeTextField: fakeTextField!, viewController: viewController!)
   }
   
   func doneButtonPressed() {
      self.save {
         self.router.closeCurrentViewController()
      }
   }
   
   func backButtonPressed() {
      self.router.closeCurrentViewController()
   }
}

// MARK: - Create new Post

extension NewPostPresenter {
   
   private func save(_ completed: @escaping () -> Void) {
      guard let data = editor.buildNewPostData() else {
         return
      }
      interactor.saveNewPost(data: data, completed)
   }
}
