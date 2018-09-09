//
//  SettingsProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

protocol SettingsDependenciesProtocol {
   func configure(_ view: SettingsViewController)
}

protocol SettingsViewProtocol: class {
   var presenter: SettingsPresenterProtocol! {get set}
   func setUpTitle(text: String)
   func reConfigureView()
}

protocol SettingsPresenterProtocol: class {
   var router: SettingsPouterProtocol! {get set}
   func configureView()
   func reConfigureView()
   func backButtonPressed()
   func didSelelectMenuItem(for menuIndex: Int)
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

protocol SettingsPouterProtocol: class {
   var view: SettingsViewController! {get set}
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
   func didSelelectMenuItem(for menuIndex: Int)
   func didSelect(menuItem: SettingsMenu)
   func closeCurrentViewController()
}

protocol SettingsMenuProtocol {
   var output: SettingsPresenterProtocol! {get}
   var viewModel: SettingsViewModelProtocol! {get}
   func configure(with tableView: UITableView)
}

protocol SettingsViewModelProtocol {
   var model: [SettingsSectionedModel] {get set}
   var selectedMenuItem: AnyObserver<SettingsMenu> {get set}
   
}
