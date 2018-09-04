//
//  SettingsViewController.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/20/17.
//  Copyright © 2017 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewController: UIViewController, SettingsViewProtocol {

   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   var presenter: SettingsPresenterProtocol!
   var menuController: SettingsMenuController!

   private let configurator = SettingsDependencies()
   private let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      configurator.configure(self)
      presenter.configureView()
      configureMenu()
      setUpHandlers()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      presenter.reConfigureView()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      presenter.prepare(for: segue, sender: sender)
   }
   
   func setUpTitle(text: String) {
      self.title = text
   }

   private func setUpHandlers() {
      configure(item: backBarButtonItem)
      configure(item: tableView)
   }
   
   private func configure(item: NSObject) {
      switch item {
      case backBarButtonItem:
         self.backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.presenter.backButtonPressed()
         }).disposed(by: disposeBag)
      case tableView:
         tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
               self?.presenter.didSelelectMenuItem(for: indexPath.row)
            }).disposed(by: disposeBag)
      default:
         break
      }
   }
   
   private func configureMenu() {
      tableView.delegate = menuController
      tableView.dataSource = menuController
   }
   
   func reConfigureView() {
      tableView.reloadData()
   }
}
