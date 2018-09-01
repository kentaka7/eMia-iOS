//
//  LoginPresenter.swift
//  eMia
//

import UIKit
import RxSwift

class LoginPresenter: NSObject, LogInValidating, LogInActing, LogInRouting {

   var interactor: LoginInteractor!
   var view: LogInViewController!

   var email = BehaviorSubject<String>(value: "")
   var password = BehaviorSubject<String>(value: "")
   
   // Computed property to retunr the result of expected validation
   var isValid: Observable<Bool> {
      return Observable.combineLatest(email.asObservable(), password.asObservable()) { emailString, passwordString in
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
      do {
         interactor.signIn(email: try email.value(), password: try password.value()) { success in
            self.stopProgress()
            if success {
               presentMainScreen()
            } else {
               completion(.accessDenied)
            }
         }
      } catch {
         print(error)
         completion(.accessDenied)
      }
   }
   
   func signUp(completion: (LoginPresenter.LoginError?) -> Void) {
      do {
         let name = try email.value().components(separatedBy: "@").first!
         let user = UserModel(name: name, email: try email.value(), address: nil, gender: nil, yearbirth: nil)
         let password = try self.password.value()
         AppDelegate.instance.appRouter.transition(to: .myProfile(user, password), type: .push)
      } catch {
         print(error)
         completion(.accessDenied)
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
