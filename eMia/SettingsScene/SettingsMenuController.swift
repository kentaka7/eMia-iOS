//
//  SettingsMenuController.swift
//  eMia
//
//  Created by Сергей Кротких on 02/09/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/**
 * SettingsMenuController
 * binds Menu enum with UITableView
 */

class SettingsMenuController: NSObject, SettingsMenuProtocol, UITableViewDelegate, UITableViewDataSource {

   weak var output: SettingsPresenterProtocol!
   var viewModel: SettingsViewModelProtocol!
   let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }
   
   func configure(with tableView: UITableView) {
      tableView.delegate = self
      tableView.dataSource = self
      
      tableView.rx.itemSelected
         .subscribe(onNext: {[weak self] indexPath in
            self?.output.didSelelectMenuItem(for: indexPath.row)
         }).disposed(by: disposeBag)
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(tableView, for: indexPath)
   }
   
   private func cell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
      let menuItem = SettingsMenu(rawValue: indexPath.row)!
      switch menuItem {
      case .myProfile:
         return tableView.dequeueCell(ofType: MyProfile1ViewCell.self)!.then { cell in
            cell.configure()
         }
      case .visitToAppSite:
         return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
            cell.titleLabel.text = menuItem.title
         }
      case .logOut:
         return tableView.dequeueCell(ofType: MyProfile2ViewCell.self)!.then { cell in
            cell.titleLabel.text = menuItem.title
         }
      }
   }
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      switch SettingsMenu(rawValue: indexPath.row)! {
      case .myProfile:
         return 64.0
      case .visitToAppSite:
         return 52.0
      case .logOut:
         return 52.0
      }
   }
   
   var numberOfRows: Int {
      return SettingsMenu.allValues.count
   }
}
