//
//  SettingsPresenter.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import Then

/**
 * SettingsPresenter is an example of the presenter for the SettingsViewController
 */

class SettingsPresenter: NSObject, SettingsPresenterProtocol {

   weak var view: SettingsViewProtocol!
   var router: SettingsPouterProtocol!
   
   deinit {
      Log()
   }

   func configureView() {
      view.setUpTitle(text: "Settings".localized)
   }
   
   func reConfigureView() {
      view.reConfigureView()
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
