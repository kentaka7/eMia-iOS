//
//  SettingsRouter.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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
      didSelect(menuItem: SettingsMenu(rawValue: menuIndex)!)
   }
   
   func didSelect(menuItem: SettingsMenu) {
      switch menuItem {
      case .myProfile:
         if gUsersManager.currentUser != nil {
            self.view.performSegue(withIdentifier: Segue.MyProfileViewController, sender: self)
         }
      case .visitToAppSite:
         gotoOurSite()
      case .logOut:
         gUsersManager.logOut()
      }
   }
   
   private func gotoOurSite() {
      if let url = URL(string: "http://www.coded.dk") {
         UIApplication.shared.open(url, options: [:])
      }
   }
}
