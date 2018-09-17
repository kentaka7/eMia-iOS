//
//  SettingsProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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

protocol SettingsIputProtocol {
   func configure(view: ShortMenuViewItemProtocol, with menuItem: SettingsMenu)
}

protocol ShortMenuViewItemProtocol {
   func setTitle(_ text: String?)
   func setImage(_ image: UIImage?)
}
