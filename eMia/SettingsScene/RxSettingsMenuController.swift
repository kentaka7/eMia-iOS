//
//  SettingsMenuController.swift
//  eMia
//
//  Created by Сергей Кротких on 02/09/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift
import Differentiator

/**
 * RxSettingsMenuController
 * binds Menu enum with UITableView with custom cells
 */

class RxSettingsMenuController: NSObject, SettingsMenuProtocol {
   weak var output: SettingsPresenterProtocol!
   private weak var tableView: UITableView!
   let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }
   
   func configure(with tableView: UITableView) {
      self.tableView = tableView
      let sections: [SettingsSectionedModel] = [
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
      
      let dataSource = RxSettingsMenuController.dataSource()
      
      Observable.just(sections)
         .bind(to: tableView.rx.items(dataSource: dataSource))
         .disposed(by: disposeBag)
      
      tableView.rx.itemSelected
         .subscribe(onNext: {[weak self] indexPath in
            let section = indexPath.section
            let count = section > 0 ? sections[section - 1].items.count : 0
            let index = count + indexPath.row
            self?.output.didSelelectMenuItem(for: index)
         }).disposed(by: disposeBag)
   }
}

extension RxSettingsMenuController {
   static func dataSource() -> RxTableViewSectionedReloadDataSource<SettingsSectionedModel> {
      return RxTableViewSectionedReloadDataSource<SettingsSectionedModel>(
         configureCell: { (dataSource, tableView, idxPath, _) in
            switch dataSource[idxPath] {
            case .myProfile:
               return tableView.dequeueCell(ofType: MyProfile1ViewCell.self)!.then { cell in
                  cell.configure()
               }
            case .visitToAppSite:
               return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
                  cell.titleLabel.text = "Visit to the app site".localized
               }
            case .logOut:
               return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
                  cell.titleLabel.text = "Log Out".localized
               }
            }
      },
         titleForHeaderInSection: { dataSource, index in
            let section = dataSource[index]
            return section.title
      }
      )
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

