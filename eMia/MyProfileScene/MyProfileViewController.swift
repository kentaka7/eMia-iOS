//
//  MyProfileViewController.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

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

   deinit {
      Log()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationItem.title = registrationNewUser ? "Sign Up".localized : "My Profile".localized
      
      configurator.configure(self, user: user)
      presenter.configureView()
   }
}
