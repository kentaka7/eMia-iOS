//
//  MyProfileRouter.swift
//  eMia
//
//  Created by Сергей Кротких on 31/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

class MyProfileRouter: MyProfilePouterProtocol {

   var view: MyProfileViewProtocol!
   
   func closeScene() {
      self.view.close()
   }
   
   func goToNextScene() {
      if self.view.registrationNewUser {
         presentMainScreen()
      } else {
         self.closeScene()
      }
   }
   
}
