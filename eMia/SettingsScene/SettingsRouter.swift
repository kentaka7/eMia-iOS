//
//  SettingsRouter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class SettingsRouter: SettingsPouterProtocol {

   weak var view: SettingsViewController!
   
   deinit {
      Log()
   }
   
   func closeCurrentViewController() {
      self.view.navigationController?.popViewController(animated: true)
   }
   
   struct Segue {
      static let MyProfileViewController = "registerSegue"
   }
   
   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let myProfileViewController = segue.destination as? MyProfileViewController {
         if let currentUser = gUsersManager.currentUser {
            myProfileViewController.user = currentUser
         }
      }
   }

   func didSelelectMenuItem(for menuIndex: Int) {
      switch SettingsMenu(rawValue: menuIndex)! {
      case .myProfile:
         if gUsersManager.currentUser != nil {
            self.view.performSegue(withIdentifier: Segue.MyProfileViewController, sender: self)
         }
      case .visitToAppSite:
         AppDelegate.instance.gotoCustomerSite()
      case .logOut:
         gUsersManager.logOut()
      }
   }
}
