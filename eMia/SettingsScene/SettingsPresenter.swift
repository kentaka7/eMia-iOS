//
//  SettingsPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import Then
import RxSwift
import RxCocoa

/**
 * SettingsPresenter is an example of the view model for SettingsViewController
 * It binds Menu enum with UITableView
 */

class SettingsPresenter: NSObject, SettingsPresenterProtocol {
   
   enum Menu: Int {
      case myProfile
      case visitToAppSite
      case logOut
      static let allValues = [myProfile, visitToAppSite, logOut]
   }

   weak var view: SettingsViewProtocol!
   var router: SettingsPouterProtocol!
   
   private let disposeBug = DisposeBag()
   
   private var tableView: UITableView! {
      return view.tableView
   }

   deinit {
      Log()
   }

   func configureView() {
      configureTableView()
      configureBackButton()
      configureRouter()
   }
   
   func viewWillAppear() {
      tableView.reloadData()
   }

   private func configureTableView() {
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   private func configureBackButton() {
      view.backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.router.closeScene()
      }).disposed(by: disposeBug)
   }
   
   private func configureRouter() {
      tableView.rx.itemSelected
         .subscribe(onNext: { indexPath in
            self.router.selelectMenuItem(for: indexPath.row)
         })
         .disposed(by: disposeBug)
   }
   
   func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      router.prepare(for: segue, sender: sender)
   }
}

// MARK: - Table View delegate protocol

extension SettingsPresenter: UITableViewDelegate, UITableViewDataSource {
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(for: indexPath)
   }
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch Menu(rawValue: indexPath.row)! {
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
   }
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      switch Menu(rawValue: indexPath.row)! {
      case .myProfile:
         return 64.0
      case .visitToAppSite:
         return 52.0
      case .logOut:
         return 52.0
      }
   }
   
   var numberOfRows: Int {
      return Menu.allValues.count
   }
}
