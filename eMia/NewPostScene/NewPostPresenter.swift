//
//  NewPostPresenter.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

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
   
   deinit {
      Log()
   }
   
   func configureView() {
      setUpTitle()
   }

   private func setUpTitle() {
      let title = "\(AppConstants.ApplicationName) - My new post".localized
      view.setUpTitle(text: title)
   }
   
   func doneButtonPressed() {
      self.interactor.save {
         self.router.closeCurrentViewController()
      }
   }
   
   func backButtonPressed() {
      self.router.closeCurrentViewController()
   }
}
