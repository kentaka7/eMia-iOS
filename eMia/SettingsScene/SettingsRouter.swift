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
      static let MyProfileViewController = "registerSegue"
   }
   
   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let myProfileViewController = segue.destination as? MyProfileViewController {
         if let currentUser = gUsersManager.currentUser {
            myProfileViewController.user = currentUser
         }
      }
   }

   func prepare(for tableView: UITableView, viewController: UIViewController) {
      tableView.rx.itemSelected
         .subscribe(onNext: { indexPath in
            switch SettingsPresenter.Menu(rawValue: indexPath.row)! {
            case .myProfile:
               if gUsersManager.currentUser != nil {
                  viewController.performSegue(withIdentifier: Segue.MyProfileViewController, sender: self)
               }
            case .visitToAppSite:
               AppDelegate.instance.gotoCustomerSite()
            case .logOut:
               gUsersManager.logOut()
            }
         })
         .disposed(by: disposeBag)
   }
}
