//
//  SettingsDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class SettingsDependencies: SettingsDependenciesProtocol {

   func configure(view: SettingsViewController) {
      let presenter = SettingsPresenter()
      let router = SettingsRouter()
      
      view.presenter = presenter

      presenter.view = view
      presenter.router = router

      router.view = view
   }
}
