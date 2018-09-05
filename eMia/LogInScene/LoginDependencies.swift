//
//  LoginDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class LoginDependencies: LogInDependenciesProtocol {
   
   func configure(_ view: LogInViewController) {
      let presenter = LoginPresenter()
      let interactor = LoginInteractor()
      let router = LoginRouter()
      
      view.presenter = presenter
      view.validator = presenter
      
      presenter.interactor = interactor
      presenter.view = view
      presenter.router = router

      router.viewController = view
   }
}
