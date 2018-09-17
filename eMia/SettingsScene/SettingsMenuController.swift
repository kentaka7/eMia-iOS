//
//  SettingsMenuController.swift
//  eMia
//
//  Created by Sergey Krotkih on 02/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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
   var input: SettingsIputProtocol!
   var viewModel: SettingsViewModelProtocol!
   let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }
   
   func configure(with tableView: UITableView) {
      tableView.delegate = self
      tableView.dataSource = self

      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 50
      
      tableView.rx.itemSelected
         .subscribe(onNext: {[weak self] indexPath in
            self?.output.didSelelectMenuItem(for: indexPath.row)
         }).disposed(by: disposeBag)
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(tableView, for: indexPath)
   }
   
   private func cell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
      let menuItem = SettingsMenu(rawValue: indexPath.row)!
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
   }
   
   var numberOfRows: Int {
      return SettingsMenu.allValues.count
   }
}
