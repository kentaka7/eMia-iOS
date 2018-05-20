//
//  RegisterViewController.swift
//  eMia
//

import UIKit
import NVActivityIndicatorView

class RegisterViewController: UIViewController {
   
   @IBOutlet weak var signUpButton: UIButton!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   @IBOutlet weak var tableView: UITableView!
   
   var user: UserModel?
   var password: String?
   
   var presenter: RegisterPresenter!
   var interactor: RegisterInteractor!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationItem.title = "My Profile".localized

      // TODO: External injection (from the login screen)
      user = UserModel()
      password = ""
      
      RegisterDependencies.configure(view: self, tableView: tableView, user: user, password: password)
      
      configure(signUpButton)
      configure(tableView)
   }
   
   @IBAction func backButtonPressed(_ sender: Any) {
      navigationController?.popViewController(animated: true)
   }
   
   @IBAction func signUpButtonPressed(_ sender: Any) {
      interactor.registerNewUser()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case signUpButton:
         signUpButton.layer.cornerRadius = signUpButton.frame.height / 2.0
         signUpButton.backgroundColor = GlobalColors.kBrandNavBarColor
      case tableView:
         tableView.delegate = self
         tableView.dataSource = self
      default:
         break
      }
   }
}

// MARK: - UITableView delegate protocol

extension RegisterViewController: UITableViewDelegate, UITableViewDataSource {
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return presenter.numberOfRows
   }

   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return presenter.tableView(tableView, heightCellFor: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return presenter.cell(for: indexPath)
   }
}
