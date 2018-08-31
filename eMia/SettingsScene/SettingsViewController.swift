//
//  SettingsViewController.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/20/17.
//  Copyright © 2017 Coded I/S. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, SettingsViewProtocol {

   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   var presenter: SettingsPresenterProtocol!
   
   private let configurator = SettingsDependencies()

   deinit {
      Log()
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      configurator.configure(view: self)
      presenter.configureView()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      presenter.viewWillAppear()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      presenter.prepare(for: segue, sender: sender)
   }
   
   func close() {
      navigationController?.popViewController(animated: true)
   }
}
