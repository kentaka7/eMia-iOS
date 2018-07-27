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

class MyProfileViewController: UIViewController {
   var presenter: MyProfilePresenting!

   var user: UserModel!
   var password: String!
   var registerUser: Bool!
   private let disposeBug = DisposeBag()
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

   @IBOutlet weak var saveDataButton: UIButton!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      registerUser = user.userId.isEmpty
      
      navigationItem.title = registerUser ? "Sign Up".localized : "My Profile".localized

      configure(tableView)
      configure(saveDataButton)
      configure(view)
      
      MyProfileDependencies.configure(view: self, tableView: tableView, user: user)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case self.view:
         backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.closeWindow()
         }).disposed(by: disposeBug)
      case saveDataButton:
         saveDataButton.layer.cornerRadius = saveDataButton.frame.height / 2.0
         saveDataButton.backgroundColor = GlobalColors.kBrandNavBarColor
         saveDataButton.rx.tap.bind(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.saveData()
         }).disposed(by: disposeBug)
      case tableView:
         tableView.delegate = self
         tableView.dataSource = self
      default:
         break
      }
   }
   
   private func saveData() {
      presenter.updateMyProfile { [weak self] in
         guard let `self` = self else { return }
         if self.registerUser {
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

extension MyProfileViewController: UITableViewDelegate, UITableViewDataSource {
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return presenter.numberOfRows
   }

   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return presenter.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return presenter.cell(for: indexPath)
   }
}
