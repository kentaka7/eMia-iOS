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

   private var editor: MyProfileEditor!

   deinit {
      Log()
   }

   func configureView() {
      setUpEditor()
   }
   
   private func setUpEditor() {
      editor = MyProfileEditor(with: user, viewController: self.viewController, tableView: view.tableView, locationWorker: locationWorker)
   }
   
   func backButtonPressed() {
      self.router.closeCurrentViewController()
   }
   
   func doneButtonPressed() {
      self.saveData()
   }
   
   private func saveData() {
      guard let data = editor.myProfileData() else {
         return
      }
      self.interactor.updateProfile(for: data) {
         self.router.goToNextScene()   // documented: press alt+click to see the description
      }
   }
}
