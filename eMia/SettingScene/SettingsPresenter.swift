//
//  SettingsPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import Then

class SettingsPresenter: NSObject, TableViewPresentable {
   
   enum Menu: Int {
      case MyProfile
      case VisitToAppSite
      case LogOut
      static let allValues = [MyProfile, VisitToAppSite, LogOut]
   }

   weak var tableView: UITableView!
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch Menu(rawValue: indexPath.row)! {
      case .MyProfile:
         return tableView.dequeueCell(ofType: MyProfile1ViewCell.self).then { cell in
            cell.configure()
         }
      case .VisitToAppSite:
         return tableView.dequeueCell(ofType: MyProfile2ViewCell.self).then { cell in
            cell.titleLabel.text = "Visit to the app site".localized
         }
      case .LogOut:
         return tableView.dequeueCell(ofType: MyProfile2ViewCell.self).then { cell in
            cell.titleLabel.text = "Log Out".localized
         }
      }
   }

   func heightCell(for indexPath: IndexPath) -> CGFloat {
      switch Menu(rawValue: indexPath.row)! {
      case .MyProfile:
         return 64.0
      case .VisitToAppSite:
         return 52.0
      case .LogOut:
         return 52.0
      }
   }

   var numberOfRows: Int {
      return Menu.allValues.count
   }
}
