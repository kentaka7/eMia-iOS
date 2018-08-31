//
//  SettingsRouter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift

class SettingsRouter: SettingsPouterProtocol {

   private let disposeBag = DisposeBag()

   weak var view: SettingsViewProtocol!
   
   deinit {
      Log()
   }
   
   func closeScene() {
      self.view.close()
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

   func selelectMenuItem(for menuIndex: Int) {
      switch SettingsPresenter.Menu(rawValue: menuIndex)! {
      case .myProfile:
         if gUsersManager.currentUser != nil {
            let viewController = self.view as! UIViewController
            viewController.performSegue(withIdentifier: Segue.MyProfileViewController, sender: self)
         }
      case .visitToAppSite:
         AppDelegate.instance.gotoCustomerSite()
      case .logOut:
         gUsersManager.logOut()
      }
   }
}
