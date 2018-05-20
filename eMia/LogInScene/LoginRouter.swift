//
//  LoginRouter.swift
//  eMia
//

import UIKit

class LoginRouter: NSObject {

   var rootViewController: LogInViewController?
   
   fileprivate var mUser: UserModel!
   fileprivate var mPassword: String!
   
   struct Storyboards {
      static let login = "Login"
   }

   struct Segue {
      static let MyProfileViewController = "editProfileSegue"
   }
   
   let rootRouter = RootWireframe()
}

// MARK: - Edit post

extension LoginRouter {
   
   func performEditProfile(_ password: String, _ user: UserModel) {
      guard let viewController = self.rootViewController else {
         return
      }
      mPassword = password
      mUser = user
      viewController.performSegue(withIdentifier: LoginRouter.Segue.MyProfileViewController, sender: self)
   }
   
   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == LoginRouter.Segue.MyProfileViewController {
         if let MyProfileViewController = segue.destination as? MyProfileViewController {
            MyProfileViewController.user = mUser
            MyProfileViewController.password = mPassword
         }
      }
   }
}
