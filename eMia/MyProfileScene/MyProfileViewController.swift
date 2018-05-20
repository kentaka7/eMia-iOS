//
//  MyProfileViewController.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyProfileViewController: UIViewController {

   var presenter: MyProfilePresenter!
   
   var user: UserModel!
   var password: String!
   
   var registerUser: Bool!
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var saveDataButton: UIButton!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      registerUser = user.userId.isEmpty
      
      navigationItem.title = registerUser ? "Sign Up".localized : "My Profile".localized
      configure(tableView)
      configure(saveDataButton)
      
      MyProfileDependencies.configure(view: self, tableView: tableView, user: user)
   }
   
   @IBAction func backButtonPressed(_ sender: Any) {
      closeWindow()
   }
   
   @IBAction func saveDataButtonPressed(_ sender: Any) {
      presenter.updateMyProfile() {
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
   
   private func configure(_ view: UIView) {
      switch view {
      case saveDataButton:
         saveDataButton.layer.cornerRadius = saveDataButton.frame.height / 2.0
         saveDataButton.backgroundColor = GlobalColors.kBrandNavBarColor
      case tableView:
         tableView.delegate = self
         tableView.dataSource = self
      default:
         break
      }
   }
}

// MARK: - UITableView delegate protocol

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
