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

   var menuController: SettingsMenuProtocol!
   
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
      bindControls()
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

   private func bindControls() {
      bindBackButton()
   }
   
   private func bindBackButton() {
      self.backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.presenter.backButtonPressed()
      }).disposed(by: disposeBag)
   }
   
   private func configureMenu() {
      menuController.configure(with: tableView)
   }
   
   func reConfigureView() {
      tableView.reloadData()
   }
}
