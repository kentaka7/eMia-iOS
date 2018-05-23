//
//  SettingsPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class SettingsPresenter: NSObject, TableViewPresentable {
   
   enum Menu: Int {
      case MyProfile
      case VisitToAppSite
      case LogOut
      static let allValues = [MyProfile, VisitToAppSite, LogOut]
   }

   internal struct CellName {
      static let myProfile1ViewCell = "MyProfile1ViewCell"
      static let myProfile2ViewCell = "MyProfile2ViewCell"
   }

   weak var tableView: UITableView!
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch Menu(rawValue: indexPath.row)! {
      case .MyProfile:
         let cell1 = tableView.dequeueReusableCell(withIdentifier: CellName.myProfile1ViewCell) as! MyProfile1ViewCell
         cell1.configure()
         return cell1
      case .VisitToAppSite:
         let cell2 = tableView.dequeueReusableCell(withIdentifier: CellName.myProfile2ViewCell) as! MyProfile2ViewCell
         cell2.titleLabel.text = "Visit to the app site".localized
         return cell2
      case .LogOut:
         let cell3 = tableView.dequeueReusableCell(withIdentifier: CellName.myProfile2ViewCell) as! MyProfile2ViewCell
         cell3.titleLabel.text = "Log Out".localized
         return cell3
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
