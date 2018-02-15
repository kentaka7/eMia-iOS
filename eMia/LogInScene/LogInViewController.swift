//
//  LogInViewController.swift
//  eMia
//

import UIKit

import NVActivityIndicatorView

class LogInViewController: UIViewController {
   
   var eventHandler: LoginPresenter!
   var presenter: LoginPresenter!
   
   @IBOutlet weak var emailTextField: UITextField!
   @IBOutlet weak var passwordTextField: UITextField!

   @IBOutlet weak var signInButton: UIButton!
   @IBOutlet weak var signUpButton: UIButton!

   @IBOutlet var activityIndicatorView: NVActivityIndicatorView!

   fileprivate var mUser: UserModel!
   fileprivate var mPassword: String!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      navigationItem.title = "Log In to ".localized + "\(AppConstants.ApplicationName)"
      LoginDependencies.configure(viewController: self)
      configureView()
   }

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      eventHandler.prepare(for: segue, sender: sender)
   }
   
   private func configureView() {
      configure(signInButton)
      configure(signUpButton)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case signInButton:
         signInButton.setTitle("Sign In".localized, for: .normal)
         signInButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
      case signUpButton:
         signUpButton.setTitle("Sign Up".localized, for: .normal)
         signUpButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
      default:
         break
      }
   }
   
   @IBAction func signInButtonPressed(_ sender: Any) {
      eventHandler.signIn(emailTextField.text, passwordTextField.text) { error in
         guard let error = error else {
            return
         }
         switch error {
            case .emailIsAbsent:
               break
            case .emailIsWrong:
               self.emailTextField.shake()
            case .passwordIsWrong:
               Alert.default.showOk("", message: error.description)
            case .accessDenied:
               self.emailTextField.shake()
         }
      }
   }
   
   @IBAction func signUpButtonPressed(_ sender: Any) {
      eventHandler.signUp(emailTextField.text, passwordTextField.text) { error in
         guard let error = error else {
            return
         }
         switch error {
         case .emailIsAbsent:
            Alert.default.showOk("", message: error.description)
         case .emailIsWrong:
            break
         case .passwordIsWrong:
            Alert.default.showOk("", message: error.description)
         case .accessDenied:
            break
         }
      }
   }
}

// MARK: - View Protocol

extension LogInViewController {
   
   func startProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.startAnimating()
      }
   }
   
   func stopProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.stopAnimating()
      }
   }
   
}
