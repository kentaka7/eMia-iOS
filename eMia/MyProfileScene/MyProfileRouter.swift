//
//  MyProfileRouter.swift
//  eMia
//
//  Created by Sergey Krotkih on 31/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

class MyProfileRouter: MyProfileRouterProtocol {

   weak var view: MyProfileViewController!

   deinit {
      Log()
   }

   func closeCurrentViewController() {
      self.view.navigationController?.popViewController(animated: true)
   }
   
   func goToNextScene(registrationNewUser: Bool) {
      if registrationNewUser {
         presentMainScreen()
      } else {
         closeCurrentViewController()
      }
   }
   
}
