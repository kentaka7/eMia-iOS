//
//  LoginDependencies.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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
