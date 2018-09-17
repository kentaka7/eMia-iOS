//
//  SettingsMenuController.swift
//  eMia
//
//  Created by Sergey Krotkih on 02/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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
   var viewModel: SettingsViewModelProtocol!
   var input: SettingsIputProtocol!
   let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }
   
   func configure(with tableView: UITableView) {
      Observable.just(viewModel.model)
         .bind(to: tableView.rx.items(dataSource: dataSource))
         .disposed(by: disposeBag)

      tableView.rx.modelSelected(SettingsMenu.self)
         .bind(to: viewModel.selectedMenuItem)
         .disposed(by: disposeBag)
   }
   
   private var dataSource: RxTableViewSectionedReloadDataSource<SettingsSectionedModel> {
      return RxTableViewSectionedReloadDataSource<SettingsSectionedModel>(
         configureCell: { (dataSource, tableView, idxPath, _) in
            let menuItem = dataSource[idxPath]
            switch menuItem {
            case .myProfile:
               return tableView.dequeueCell(ofType: MyProfile1ViewCell.self)!.then { cell in
                  self.input.configure(view: cell, with: menuItem)
               }
            case .visitToAppSite, .logOut:
               return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
                  self.input.configure(view: cell, with: menuItem)
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
