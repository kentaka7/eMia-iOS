//
//  MyProfileViewController.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import NVActivityIndicatorView

class MyProfileViewController: UIViewController, MyProfileViewProtocol {
   
   var presenter: MyProfilePresenterProtocol!
   
   var user: UserModel!
   var password: String!
   var registrationNewUser: Bool {
      return user.userId.isEmpty
   }
   private let disposeBug = DisposeBag()
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   
   @IBOutlet weak var saveDataButton: UIButton!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   private let configurator: MyProfileDependenciesProtocol = MyProfileDependencies()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationItem.title = registrationNewUser ? "Sign Up".localized : "My Profile".localized

      configurator.configure(view: self, user: user)
      presenter.configureView()
      setUpBackButton()
      setUpDoneButton()
   }
   
   private func setUpBackButton() {
      backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.closeWindow()
      }).disposed(by: disposeBug)
   }

   private func setUpDoneButton() {
      saveDataButton.setAsCircle()
      saveDataButton.backgroundColor = GlobalColors.kBrandNavBarColor
      saveDataButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.saveData()
      }).disposed(by: disposeBug)
   }

   // TODO: Move to router
   
   private func saveData() {
      presenter.updateMyProfile { [weak self] in
         guard let `self` = self else { return }
         if self.registrationNewUser {
            presentMainScreen()
         } else {
            self.closeWindow()
         }
      }
   }
   
   private func closeWindow() {
      navigationController?.popViewController(animated: true)
   }
}

