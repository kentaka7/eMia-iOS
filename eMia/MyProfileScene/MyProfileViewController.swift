//
//  MyProfileViewController.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RxSwift

class MyProfileViewController: UIViewController, MyProfileViewProtocol {
   var presenter: MyProfilePresenterProtocol!
   var editor: MyProfileEditorProtocol!
   
   weak var user: UserModel!
   var password: String!
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   
   @IBOutlet weak var saveDataButton: UIButton!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   private let configurator: MyProfileDependenciesProtocol = MyProfileDependencies()

   private let disposeBag = DisposeBag()

   deinit {
      Log()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      configurator.configure(self)
      editor.configureView()
      presenter.configureView()
      configureView()
   }

   func setUpTitle(text: String) {
      navigationItem.title = text
   }
   
   private func configureView() {
      configureDoneButton()
      setUpActivityHandlers()
   }
   
   private func configureDoneButton() {
      saveDataButton.setAsCircle()
      saveDataButton.backgroundColor = GlobalColors.kBrandNavBarColor
   }

   private func setUpActivityHandlers() {
      bindBackButton()
      bindDoneButton()
   }
   
   private func bindBackButton() {
      backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.presenter.backButtonPressed()
      }).disposed(by: disposeBag)
   }
   
   private func bindDoneButton() {
      saveDataButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.presenter.doneButtonPressed()
      }).disposed(by: disposeBag)
   }
}
