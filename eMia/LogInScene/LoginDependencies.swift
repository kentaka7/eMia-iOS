//
//  LoginDependencies.swift
//  eMia
//

import UIKit

class LoginDependencies: LogInDependenciesProtocol {
   
   func configure(_ view: LogInViewController) {
      let presenter = LoginPresenter()
      let interactor = LoginInteractor()
      
      view.presenter = presenter
      view.validator = presenter
      view.router = presenter
      
      presenter.interactor = interactor
      presenter.view = view
   }
}
