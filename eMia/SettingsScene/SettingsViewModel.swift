//
//  SettingsViewModel.swift
//  eMia
//
//  Created by Sergey Krotkih on 09/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

class SettingsViewModel: SettingsViewModelProtocol {
   weak var router: SettingsPouterProtocol!
   let disposeBag = DisposeBag()
   
   var model: [SettingsSectionedModel] = [
      .MyProfileSection(title: "My profile".localized,
                        items: [
                           .myProfile
         ]),
      .OtherSection(title: "Other".localized,
                    items: [
                     .visitToAppSite,
                     .logOut
         ])
   ]
   
   var selectedMenuItem: AnyObserver<SettingsMenu>
   
   init() {
      let _selectedMenuItem = PublishSubject<SettingsMenu>()
      self.selectedMenuItem = _selectedMenuItem.asObserver()
      _selectedMenuItem.subscribe({ (menuEvent) in
         guard let menuItem = menuEvent.element else {
            return
         }
         self.router.didSelect(menuItem: menuItem)
      }).disposed(by: disposeBag)
   }
   
}

extension SettingsViewModel: SettingsIputProtocol {
   
   func configure(view: ShortMenuViewItemProtocol, with menuItem: SettingsMenu) {
      
      switch menuItem {
      case .myProfile:
         guard let currentUser = gUsersManager.currentUser else {
            view.setImage(nil)
            view.setTitle(nil)
            return
         }
         gPhotosManager.downloadAvatar(for: currentUser.userId) { image in
            view.setImage(image)
         }
         
         view.setTitle(currentUser.name)
      case .visitToAppSite, .logOut:
         view.setTitle(menuItem.title)
      }
   }
}

enum SettingsMenu: Int {
   case myProfile
   case visitToAppSite
   case logOut
   static let allValues = [myProfile, visitToAppSite, logOut]
}

extension SettingsMenu {
   var title: String {
      switch self {
      case .myProfile:
         return "My profile".localized
      case .visitToAppSite:
         return "Visit to our site".localized
      case .logOut:
         return "Log Out".localized
      }
   }
}

enum SettingsSectionedModel {
   case MyProfileSection(title: String, items: [SettingsMenu])
   case OtherSection(title: String, items: [SettingsMenu])
}

extension SettingsSectionedModel: SectionModelType {
   typealias Item = SettingsMenu
   
   var items: [SettingsMenu] {
      switch  self {
      case .MyProfileSection:
         return [
            .myProfile
         ]
      case .OtherSection:
         return [
            .visitToAppSite,
            .logOut
         ]
      }
   }
   
   init(original: SettingsSectionedModel, items: [Item]) {
      switch original {
      case let .MyProfileSection(title: title, items: _):
         self = .MyProfileSection(title: title, items: items)
      case let .OtherSection(title: title, items: _):
         self = .OtherSection(title: title, items: items)
      }
   }
}

extension SettingsSectionedModel {
   var title: String {
      switch self {
      case .MyProfileSection:
         return "My profile".localized
      case .OtherSection:
         return "Other".localized
      }
   }
}
