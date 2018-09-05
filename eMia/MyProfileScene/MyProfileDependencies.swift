//
//  MyProfileDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class MyProfileDependencies: MyProfileDependenciesProtocol {

   deinit {
      Log()
   }
   
   func configure(_ view: MyProfileViewController) {
      
      let presenter = MyProfilePresenter()
      let interactor = MyProfileInteractor()
      let router = MyProfileRouter()
      let loginInteractor = LoginInteractor()
      let locationWorker = LocationManager()
      let editor = MyProfileEditor(with: view.user, viewController: view, tableView: view.tableView, locationWorker: locationWorker)

      // Configure View
      view.presenter = presenter
      view.editor = editor

      // Configure Presenter
      presenter.view = view
      presenter.interactor = interactor
      presenter.router = router
      presenter.locationWorker = locationWorker
      presenter.viewController = view
      presenter.user = view.user

      // Configure Interactor
      interactor.loginWorker = loginInteractor
      interactor.tableView = view.tableView
      interactor.user = view.user
      interactor.password = view.password
      interactor.activityIndicator = view.activityIndicator
      interactor.input = editor
      
      // Configure Router
      router.view = view
   }
}
