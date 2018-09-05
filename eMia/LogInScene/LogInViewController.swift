//
//  LogInViewController.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import NVActivityIndicatorView

class LogInViewController: UIViewController {
   
   var presenter: LogInPresenterProtocol!
   var validator: LogInValidating!
   
   let disposeBag = DisposeBag()
   
   @IBOutlet weak var emailTextField: UITextField!
   @IBOutlet weak var passwordTextField: UITextField!

   @IBOutlet weak var signInButton: UIButton!
   @IBOutlet weak var signUpButton: UIButton!

   @IBOutlet var activityIndicatorView: NVActivityIndicatorView!
   @IBOutlet var tapRecognizer: UITapGestureRecognizer!
   
   private let configurator = LoginDependencies()

   override func viewDidLoad() {
      super.viewDidLoad()
      
      configurator.configure(self)
      presenter.configureView()
      configureView()
      bindActivities()
      subscribeOnValidation()
      emailTextField.becomeFirstResponder()
   }

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   }
   
   private func configureView() {
      configure(signInButton)
      configure(signUpButton)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case signInButton:
         signInButton.isEnabled = false
         signInButton.setTitle("Sign In".localized, for: .normal)
         signInButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
      case signUpButton:
         signUpButton.isEnabled = false
         signUpButton.setTitle("Sign Up".localized, for: .normal)
         signUpButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
      default:
         break
      }
   }

   private func bindActivities() {
      binfEmailTextField()
      bindPasswordTextField()
      bindTapOnView()
      bindSignUpButton()
      bindSignInButton()
   }

   private func binfEmailTextField() {
      _ = emailTextField.rx.text.map { $0 ?? "" }
         .bind(to: validator.email)
   }

   private func bindPasswordTextField() {
      _ = passwordTextField.rx.text.map {$0 ?? "" }
         .bind(to: validator.password)
   }
   
   private func bindTapOnView() {
      tapRecognizer.rx.event.subscribe({[weak self] _ in
         guard let `self` = self else { return }
         self.hideKeyboard()
      }).disposed(by: disposeBag)
   }
   
   private func bindSignUpButton() {
      signUpButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.signUpButtonPressed()
      }).disposed(by: disposeBag)
   }

   private func bindSignInButton() {
      signInButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.signInButtonPressed()
      }).disposed(by: disposeBag)
   }
   
   private func subscribeOnValidation() {
      _ = validator.isValid.bind(to: signInButton.rx.isEnabled)
      _ = validator.isValid.subscribe(onNext: {[weak self] isValid in
         guard let `self` = self else { return }
         self.signInButton.isEnabled = isValid ? true : false
         self.signInButton.setTitleColor(isValid ? UIColor.green : UIColor.lightGray, for: .normal)
         self.signUpButton.isEnabled = isValid ? true : false
         self.signUpButton.setTitleColor(isValid ? UIColor.green : UIColor.lightGray, for: .normal)
      })
   }
   
   private func signInButtonPressed() {
      self.hideKeyboard()
      startProgress()
      presenter.signInButtonPressed() { [weak self] in
         self?.stopProgress()
      }
   }
   
   private func signUpButtonPressed() {
      self.hideKeyboard()
      startProgress()
      presenter.signUpButtonPressed() { [weak self] in
         self?.stopProgress()
      }
   }
}

// MARK: - View Protocol

extension LogInViewController: LoginViewProtocol {

   func setUpTitle(text: String) {
      navigationItem.title = text
   }

   func showSignInResult(_ error: LoginPresenter.LoginError) {
      switch error {
      case .passwordIsWrong:
         self.passwordTextField.shake()
      case .accessDenied, .emailIsWrong, .emailIsAbsent:
         self.emailTextField.shake()
      }
   }
   
   func showSignUpResult(_ error: LoginPresenter.LoginError) {
      switch error {
      case .emailIsAbsent, .emailIsWrong, .passwordIsWrong:
         break
      case .accessDenied:
         Alert.default.showOk("Access denied!".localized, message: "Please check email and try it again.".localized)
      }
   }

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

extension LogInViewController: UITextFieldDelegate {

   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == emailTextField {
         passwordTextField.becomeFirstResponder()
      } else {
         self.hideKeyboard()
      }
      return false
   }
   
   private func hideKeyboard() {
      DispatchQueue.main.async {
         self.view.endEditing(true)
      }
   }
   
}
