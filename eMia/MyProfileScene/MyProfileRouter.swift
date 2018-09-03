//
//  MyProfileRouter.swift
//  eMia
//
//  Created by Сергей Кротких on 31/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
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
   
   func goToNextScene() {
      if self.view.registrationNewUser {
         presentMainScreen()
      } else {
         self.closeCurrentViewController()
      }
   }
   
}
