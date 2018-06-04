//
//  LoginDependencies.swift
//  eMia
//

import UIKit

class LoginDependencies {
   
   static func configure(view: LogInViewController) {
      let presenter = LoginPresenter()
      let interactor = LoginInteractor()
      
      view.executor = presenter
      view.validator = presenter
      view.router = presenter
      
      presenter.interactor = interactor
      presenter.view = view
   }
}
