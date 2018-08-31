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
   
   func configure(view: MyProfileViewController, user: UserModel?) {
      
      // Configure Interactor
      let presenter = MyProfilePresenter()
      let interactor = MyProfileInteractor()
      let router = MyProfileRouter()
      let loginInteractor = LoginInteractor()
      let locationWorker = LocationManager()

      // Configure View
      view.presenter = presenter

      // Configure Presenter
      presenter.view = view
      presenter.interactor = interactor
      presenter.router = router
      presenter.locationWorker = locationWorker
      presenter.viewController = view
      presenter.user = user
      presenter.activityIndicator = view.activityIndicator

      // Configure Interactor
      interactor.loginWorker = loginInteractor
      interactor.tableView = view.tableView
      interactor.user = user
      interactor.password = view.password
      interactor.activityIndicator = view.activityIndicator
      
      // Configure Router
      router.view = view
      
   }
}
