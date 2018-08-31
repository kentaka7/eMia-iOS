//
//  SettingsProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol SettingsDependenciesProtocol {
   func configure(view: SettingsViewController)
}

protocol SettingsViewProtocol: class {
   var presenter: SettingsPresenterProtocol! {get set}
   var tableView: UITableView! {get set}
   var backBarButtonItem: UIBarButtonItem! {get set}
   func close()
}

protocol SettingsPresenterProtocol: class {
   var router: SettingsPouterProtocol! {get set}
   func viewWillAppear()
   func configureView()
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

protocol SettingsPouterProtocol: class {
   var view: SettingsViewProtocol! {get set}
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
   func selelectMenuItem(for menuIndex: Int)
   func closeScene()
}
