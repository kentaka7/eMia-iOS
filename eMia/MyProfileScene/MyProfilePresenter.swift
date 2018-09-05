//
//  MyProfilePresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class MyProfilePresenter: NSObject, MyProfilePresenterProtocol {

   // Strong Dependencies
   var interactor: MyProfileInteractorProtocol!
   var router: MyProfileRouterProtocol!
   var locationWorker: MyProfileLocationWorker!

   // Weak Dependencies
   weak var view: MyProfileViewProtocol!
   weak var viewController: UIViewController!
   weak var user: UserModel!

   // Private vars
   private var registrationNewUser: Bool {
      return user.userId.isEmpty
   }
   
   deinit {
      Log()
   }

   func configureView() {
      setUpTitle()
   }
   
   func backButtonPressed() {
      self.router.closeCurrentViewController()
   }
   
   func doneButtonPressed() {
      self.interactor.saveData() {
         self.router.goToNextScene(registrationNewUser: self.registrationNewUser)   // by press on alt+click you can see description of this method
      }
   }
}

// MARK: - Private methods

extension MyProfilePresenter {
   
   private func setUpTitle() {
      let title = registrationNewUser ? "Sign Up".localized : "My Profile".localized
      view.setUpTitle(text: title)
   }
}
