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
      interactor.tableView = view.tableView
      interactor.user = user
      interactor.password = view.password
      interactor.registrationNewUser = view.registrationNewUser
      interactor.loginInteractor = loginInteractor
      interactor.activityIndicator = view.activityIndicator

      // Configure Presenter
      let locationManager = LocationManager()

      let presenter = MyProfilePresenter()
      presenter.locationManager = locationManager
      presenter.viewController = view
      presenter.view = view
      presenter.user = user
      presenter.activityIndicator = view.activityIndicator
      presenter.interactor = interactor
      
      // Configure View
      view.presenter = presenter
   }
}
