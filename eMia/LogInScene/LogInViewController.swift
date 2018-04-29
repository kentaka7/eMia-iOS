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

      enableLoginButton(false)
      
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
      if validate(username: emailTextField.text, password: passwordTextField.text) {
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

// Login credentials on verification

extension LogInViewController {

   private func validate(username: String?, password: String?) -> Bool {
      guard let username = username, let password = password,
         username.count >= 5,
         password.count >= 5 else {
            return false
      }
      return true
   }
   
   private func enableLoginButton(_ enable: Bool) {
      signInButton.isEnabled = enable
      signInButton.alpha = enable ? 1.0 : 0.5
   }
}

extension LogInViewController: UITextFieldDelegate {

   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var usernameText = emailTextField.text
      var passwordText = passwordTextField.text
      if let text = textField.text {
         let proposed = (text as NSString).replacingCharacters(in: range, with: string)
         if textField == emailTextField {
            usernameText = proposed
         } else {
            passwordText = proposed
         }
      }
      let isValid = validate(username: usernameText,
                             password: passwordText)
      enableLoginButton(isValid)
      return true
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == emailTextField {
         emailTextField.becomeFirstResponder()
      } else {
         passwordTextField.resignFirstResponder()
         if validate(username: emailTextField.text,
                     password: passwordTextField.text) {
            signInButtonPressed(signInButton)
         }
      }
      return false
   }
   
}
