//
//  LoginPresenter.swift
//  eMia
//

import UIKit
import RxSwift

protocol LogInValidating {
   var email: Variable<String> {get}
   var password: Variable<String> {get}
   var isValid : Observable<Bool> {get}
}

protocol LogInExecuted {
   func signIn(completion: @escaping (LoginPresenter.LoginError?) -> Void)
   func signUp(completion: (LoginPresenter.LoginError?) -> Void)
}

protocol LogInRouting {
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
}


class LoginPresenter: NSObject, LogInValidating, LogInExecuted, LogInRouting {

   var interactor: LoginInteractor!
   var view: LogInViewController!

   var email = Variable<String>("")
   var password = Variable<String>("")
   
   // Computed property to retunr the result of expected validation
   var isValid : Observable<Bool> {
      return Observable.combineLatest(email.asObservable(), password.asObservable()){ emailString, passwordString in
         emailString.isValidEmail() && passwordString.count > 6
      }
   }
   
   func startProgress() {
      view.startProgress()
   }
   
   func stopProgress() {
      view.stopProgress()
   }

   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   }
   
   func signIn(completion: @escaping (LoginPresenter.LoginError?) -> Void) {
      startProgress()
      interactor.signIn(email: email.value, password: password.value) { success in
         self.stopProgress()
         if success {
            presentMainScreen()
         } else {
            completion(.accessDenied)
         }
      }
   }
   
   func signUp(completion: (LoginPresenter.LoginError?) -> Void) {
      let name = email.value.components(separatedBy: "@").first!
      let user = UserModel(name: name, email: email.value, address: nil, gender: nil, yearbirth: nil)
      let password = self.password.value
      AppDelegate.instance.appRouter.transition(to: .myProfile(user, password), type: .push)
   }
}

// MARK: - Error

extension LoginPresenter {
   
   public enum LoginError: Error, CustomStringConvertible
   {
      case emailIsAbsent
      case emailIsWrong
      case passwordIsWrong
      case accessDenied
      
      public var description : String {
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
