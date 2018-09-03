//
//  SettingsMenuController.swift
//  eMia
//
//  Created by Сергей Кротких on 02/09/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

enum SettingsMenu: Int {
   case myProfile
   case visitToAppSite
   case logOut
   static let allValues = [myProfile, visitToAppSite, logOut]
}

class SettingsMenuController: NSObject, UITableViewDelegate, UITableViewDataSource {

   deinit {
      Log()
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(tableView, for: indexPath)
   }
   
   private func cell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
      switch SettingsMenu(rawValue: indexPath.row)! {
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
      switch SettingsMenu(rawValue: indexPath.row)! {
      case .myProfile:
         return 64.0
      case .visitToAppSite:
         return 52.0
      case .logOut:
         return 52.0
      }
   }
   
   var numberOfRows: Int {
      return SettingsMenu.allValues.count
   }
}
