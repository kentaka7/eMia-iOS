//
//  LoginPresenter.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift

enum LoginError: Error, CustomStringConvertible {
   case emailIsAbsent
   case emailIsWrong
   case passwordIsWrong
   case accessDenied
   
   public var description: String {
      switch self {
      case .emailIsAbsent:
         return "Please enter your email address".localized
      case .emailIsWrong:
         return "Email is wrong".localized
      case .passwordIsWrong:
         return "Please enter password (at least 6 characters)".localized
      case .accessDenied:
         return "Access denied. Please check password and try it again".localized
      }
   }
}

class LoginPresenter: NSObject, LogInValidating, LogInPresenterProtocol {

   var interactor: LoginInteractor!
   var view: LoginViewProtocol!
   var router: LoginRouterProtocol!

   var email = BehaviorSubject<String>(value: "")
   var password = BehaviorSubject<String>(value: "")
   
   /// Observable bool property. Checks to valid email and password.
   var isValid: Observable<Bool> {
      return Observable.combineLatest(email.asObservable(), password.asObservable()) { emailString, passwordString in
         emailString.isValidEmail() && passwordString.count > 6
      }
   }
   
   func configureView() {
      setUpTitle()
   }

   func setUpTitle() {
      let title = "Log In to ".localized + "\(AppConstants.ApplicationName)"
      view.setUpTitle(text: title)
   }

   func signInButtonPressed(_ completion: @escaping () -> Void) {
      do {
         let email = try self.email.value()
         let password = try self.password.value()
         interactor.signIn(email: email, password: password) { success in
            completion()
            self.didSignInFinish(success: success)
         }
      } catch {
         print(error)
         completion()
         self.didSignInFinish(success: false)
      }
   }
   
   func signUpButtonPressed(_ completion: @escaping () -> Void) {
      do {
         let email = try self.email.value()
         let password = try self.password.value()
         completion()
         didSignUpFinish(success: true, email: email, password: password)
      } catch {
         completion()
         didSignUpFinish(success: false)
      }
   }
   
   private func didSignInFinish(success: Bool) {
      if success {
         self.router.goToMainScreen()
      } else {
         self.view.showSignInResult(.accessDenied)
      }
   }

   private func didSignUpFinish(success: Bool, email: String = "", password: String = "") {
      if success {
         let user = UserModel.registerUserWith(email: email)
         self.router.goToMyProfileEditor(user, password: password)
      } else {
         self.view.showSignUpResult(.accessDenied)
      }
   }
}
