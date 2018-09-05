//
//  LoginPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift

class LoginPresenter: NSObject, LogInValidating, LogInPresenterProtocol {

   var interactor: LoginInteractor!
   var view: LoginViewProtocol!
   var router: LoginRouterProtocol!

   var email = BehaviorSubject<String>(value: "")
   var password = BehaviorSubject<String>(value: "")
   
   // Computed property to retunr the result of expected validation
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
         interactor.signIn(email: try email.value(), password: try password.value()) { success in
            completion()
            if success {
               self.router.goToMainScreen()
            } else {
               self.view.showSignInResult(.accessDenied)
            }
         }
      } catch {
         print(error)
         completion()
         self.view.showSignInResult(.accessDenied)
      }
   }
   
   func signUpButtonPressed(_ completion: @escaping () -> Void) {
      do {
         let name = try email.value().components(separatedBy: "@").first!
         let user = UserModel(name: name, email: try email.value(), address: nil, gender: nil, yearbirth: nil)
         let password = try self.password.value()
         completion()
         self.router.goToMyProfileEditor(user, password: password)
      } catch {
         completion()
         self.view.showSignUpResult(.accessDenied)
      }
   }
}

// MARK: - Errors presenter

extension LoginPresenter {
   
   public enum LoginError: Error, CustomStringConvertible {
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
            return "Please enter password (more than 6 characters)".localized
         case .accessDenied:
            return "Access denied. Please check password an try again".localized
         }
      }
   }
}
