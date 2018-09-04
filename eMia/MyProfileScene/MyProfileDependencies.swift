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
   
   func configure(_ view: MyProfileViewController, user: UserModel?) {
      
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
