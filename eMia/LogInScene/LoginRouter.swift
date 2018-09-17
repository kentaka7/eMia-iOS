//
//  LoginRouter.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

class LoginRouter: LoginRouterProtocol {

   weak var viewController: LogInViewController?
   
   deinit {
      Log()
   }

   func goToMyProfileEditor(_ user: UserModel, password: String) {
      AppDelegate.instance.appRouter.transition(to: .myProfile(user, password), type: .push)
   }
   
   func goToMainScreen() {
      AppDelegate.instance.appRouter.presentMainScreen()
   }
   
}
