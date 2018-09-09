//
//  SettingsDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class SettingsDependencies: SettingsDependenciesProtocol {

   // There are two menu controller's implementation.
   // We can select here
   private let kUseRxMenuController = false
   
   func configure(_ view: SettingsViewController) {
      let presenter = SettingsPresenter()
      let router = SettingsRouter()
      let menuController = SettingsMenuController()
      let rxMenuController = RxSettingsMenuController()
      
      view.presenter = presenter
      if kUseRxMenuController {
         view.menuController = rxMenuController
      } else {
         view.menuController = menuController
      }

      menuController.output = presenter
      rxMenuController.output = presenter
      
      presenter.view = view
      presenter.router = router

      router.view = view
   }
}
