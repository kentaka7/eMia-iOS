//
//  MyProfileViewController.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RxSwift

class MyProfileViewController: UIViewController, MyProfileViewProtocol {
   
   var presenter: MyProfilePresenterProtocol!
   
   weak var user: UserModel!
   var password: String!
   
   var registrationNewUser: Bool {
      return user.userId.isEmpty
   }
   
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
      
      navigationItem.title = registrationNewUser ? "Sign Up".localized : "My Profile".localized
      
      configurator.configure(self, user: user)
      presenter.configureView()
      self.comfigureView()
   }
   
   private func comfigureView() {
      configureDoneButton()
      bindBackButton()
      bindDoneButton()
   }
   
   private func configureDoneButton() {
      saveDataButton.setAsCircle()
      saveDataButton.backgroundColor = GlobalColors.kBrandNavBarColor
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
