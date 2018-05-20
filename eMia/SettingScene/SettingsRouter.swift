//
//  SettingsRouter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift

class SettingsRouter: NSObject {

   private let disposeBag = DisposeBag()
   
   struct Segue {
      static let editProfileViewController = "registerSegue"
   }
   
   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let editProfileViewController = segue.destination as? EditProfileViewController {
         if let currentUser = UsersManager.currentUser {
            editProfileViewController.user = currentUser
         }
      }
   }

   func prepare(for tableView: UITableView, viewController: UIViewController) {
      tableView.rx.itemSelected
         .subscribe(onNext: { indexPath in
            switch SettingsPresenter.Menu(rawValue: indexPath.row)! {
            case .MyProfile:
               if let _ = UsersManager.currentUser {
                  viewController.performSegue(withIdentifier: Segue.editProfileViewController, sender: self)
               }
            case .VisitToAppSite:
               gotoCustomerSite()
            case .LogOut:
               UsersManager.logOut()
            }
         })
         .disposed(by: disposeBag)
   }
}
