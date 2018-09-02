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
   weak var menuController: SettingsMenuController!

   private let configurator = SettingsDependencies()
   private let disposeBag = DisposeBag()
   
   deinit {
      Log()
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      configurator.configure(self)
      presenter.configureView()
      configureView()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      tableView.reloadData()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      presenter.prepare(for: segue, sender: sender)
   }
   
   private func configureView() {
      configure(view: backBarButtonItem)
      configure(view: tableView)
   }
   
   private func configure(view: NSObject) {
      switch view {
      case backBarButtonItem:
         self.backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.presenter.backButtonPressed()
         }).disposed(by: disposeBag)
      case tableView:
         tableView.delegate = menuController
         tableView.dataSource = menuController
         
         tableView.rx.itemSelected
            .subscribe(onNext: {[weak self] indexPath in
               self?.presenter.didSelelectMenuItem(for: indexPath.row)
            }).disposed(by: disposeBag)
      default:
         break
      }
   }
}
