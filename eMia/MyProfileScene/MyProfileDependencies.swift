//
//  MyProfileDependencies.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

class MyProfileDependencies: MyProfileDependenciesProtocol {

   deinit {
      Log()
   }
   
   func configure(_ view: MyProfileViewController) {
      let user = view.user
      let presenter = MyProfilePresenter()
      let interactor = MyProfileInteractor()
      let router = MyProfileRouter()
      let loginInteractor = LoginInteractor()
      let locationWorker = LocationManager()
      let viewModel = MyProfileViewModel(user: user!)
      let editor = MyProfileEditor(viewController: view, tableView: view.tableView)

      viewModel.locationWorker = locationWorker
      
      editor.viewModel = viewModel
      
      // Configure View
      view.presenter = presenter
      view.editor = editor

      // Configure Presenter
      presenter.view = view
      presenter.interactor = interactor
      presenter.router = router
      presenter.locationWorker = locationWorker
      presenter.viewController = view
      presenter.user = user

      // Configure Interactor
      interactor.loginWorker = loginInteractor
      interactor.tableView = view.tableView
      interactor.user = user
      interactor.password = view.password
      interactor.activityIndicator = view.activityIndicator
      interactor.input = editor
      
      // Configure Router
      router.view = view
   }
}
