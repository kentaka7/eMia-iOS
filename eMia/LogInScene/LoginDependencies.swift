//
//  LoginDependencies.swift
//  eMia
//

import UIKit

class LoginDependencies {
   
   static func configure(view: LogInViewController) {
      let router = LoginRouter()
      let presenter = LoginPresenter()
      let interactor = LoginInteractor()
      
      router.rootViewController = view
      
      view.executor = presenter
      view.validator = presenter
      view.router = presenter
      
      presenter.router = router
      presenter.interactor = interactor
      presenter.view = view
   }
}
