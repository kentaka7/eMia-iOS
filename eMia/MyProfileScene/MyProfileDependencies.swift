//
//  MyProfileDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class MyProfileDependencies: MyProfileDependenciesProtocol {

   func configure(view: MyProfileViewController, user: UserModel?) {
      
      // Configure Interactor
      let loginInteractor = LoginInteractor()
      let interactor = MyProfileInteractor()
      let router = MyProfileRouter()
      
      interactor.tableView = view.tableView
      interactor.user = user
      interactor.password = view.password
      interactor.loginWorker = loginInteractor
      interactor.activityIndicator = view.activityIndicator

      // Configure Presenter
      let locationWorker = LocationManager()

      let presenter = MyProfilePresenter()
      presenter.locationWorker = locationWorker
      presenter.viewController = view
      presenter.view = view
      presenter.user = user
      presenter.activityIndicator = view.activityIndicator
      presenter.interactor = interactor
      presenter.router = router
      
      // Configure Router
      router.view = view
      
      // Configure View
      view.presenter = presenter
   }
}
