//
//  SettingsPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import Then

/**
 * SettingsPresenter is an example of the view model for SettingsViewController
 * It binds Menu enum with UITableView
 */

class SettingsPresenter: NSObject, TableViewPresentable {
   
   enum Menu: Int {
      case myProfile
      case visitToAppSite
      case logOut
      static let allValues = [myProfile, visitToAppSite, logOut]
   }

   weak var tableView: UITableView!
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch Menu(rawValue: indexPath.row)! {
      case .myProfile:
         return tableView.dequeueCell(ofType: MyProfile1ViewCell.self)!.then { cell in
            cell.configure()
         }
      case .visitToAppSite:
         return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
            cell.titleLabel.text = "Visit to the app site".localized
         }
      case .logOut:
         return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
            cell.titleLabel.text = "Log Out".localized
         }
      }
   }

   func heightCell(for indexPath: IndexPath) -> CGFloat {
      switch Menu(rawValue: indexPath.row)! {
      case .myProfile:
         return 64.0
      case .visitToAppSite:
         return 52.0
      case .logOut:
         return 52.0
      }
   }

   var numberOfRows: Int {
      return Menu.allValues.count
   }
}
