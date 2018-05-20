//
//  SettingsDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class SettingsDependencies: NSObject {

   static func configure(view: SettingsViewController, tableView: UITableView) {
      let presenter = SettingsPresenter()
      view.presenter = presenter
      let router = SettingsRouter()
      view.router = router
      router.prepare(for: tableView, viewController: view)
   }
   
}
