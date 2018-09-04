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
   private var editor: MyProfileEditor!
   private var registrationNewUser: Bool {
      return user.userId.isEmpty
   }
   
   deinit {
      Log()
   }

   func configureView() {
      setUpEditor()
      setUpTitle()
   }
   
   func backButtonPressed() {
      self.router.closeCurrentViewController()
   }
   
   func doneButtonPressed() {
      self.saveData()
   }
}

// MARK: - Private methods

extension MyProfilePresenter {
   
   private func setUpEditor() {
      editor = MyProfileEditor(with: user, viewController: self.viewController, tableView: view.tableView, locationWorker: locationWorker)
   }
   
   private func setUpTitle() {
      let title = registrationNewUser ? "Sign Up".localized : "My Profile".localized
      view.setUpTitle(text: title)
   }
   
   private func saveData() {
      guard let data = editor.myProfileData() else {
         return
      }
      self.interactor.updateProfile(for: data) {
         self.router.goToNextScene(registrationNewUser: self.registrationNewUser)   // by press on alt+click you can see description of this method
      }
   }
}
