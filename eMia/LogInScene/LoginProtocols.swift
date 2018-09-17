//
//  LoginProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

protocol LogInDependenciesProtocol {
   func configure(_ view: LogInViewController)
}

protocol LoginViewProtocol {
   func showSignUpResult(_ error: LoginPresenter.LoginError)
   func showSignInResult(_ error: LoginPresenter.LoginError)
   func setUpTitle(text: String)
}

protocol LogInValidating {
   var email: BehaviorSubject<String> {get}
   var password: BehaviorSubject<String> {get}
   var isValid: Observable<Bool> {get}
}

protocol LogInPresenterProtocol {
   func configureView()
   func signInButtonPressed(_ completion: @escaping () -> Void)
   func signUpButtonPressed(_ completion: @escaping () -> Void)
}

protocol LoginRouterProtocol: class {
   var viewController: LogInViewController? {get set}
   func goToMyProfileEditor(_ user: UserModel, password: String)
   func goToMainScreen()
}
