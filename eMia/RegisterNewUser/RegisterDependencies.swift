//
//  RegisterDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class RegisterDependencies: NSObject {

   static func configure(view: RegisterViewController, tableView: UITableView, user: UserModel?, password: String?) {
      
      // Configure Interactor
      let interactor = RegisterInteractor()
      interactor.tableView = view.tableView
      interactor.user = user
      interactor.password = password

      // Configure Presenter
      let locationManager = LocationManager()

      let presenter = RegisterPresenter()
      presenter.locationManager = locationManager
      presenter.viewController = view
      presenter.tableView = view.tableView
      presenter.user = user
      presenter.password = password
      presenter.activityIndicator = view.activityIndicator
      
      // Configure View
      view.presenter = presenter
      view.interactor = interactor
   }
}
