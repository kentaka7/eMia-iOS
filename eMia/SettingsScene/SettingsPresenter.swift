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

class SettingsPresenter: NSObject, SettingsPresenterProtocol {

   weak var view: SettingsViewProtocol!
   var router: SettingsPouterProtocol!
   
   deinit {
      Log()
   }

   func configureView() {
   }
   
   func backButtonPressed() {
      self.router.closeCurrentViewController()
   }
   
   func didSelelectMenuItem(for menuIndex: Int) {
      self.router.didSelelectMenuItem(for: menuIndex)
   }
   
   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      router.prepare(for: segue, sender: sender)
   }
}
