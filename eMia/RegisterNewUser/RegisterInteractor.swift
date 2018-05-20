//
//  RegisterInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class RegisterInteractor: NSObject {
   
   struct RegisterData {
      var name: String?
      var email: String?
      var password: String?
      var address: String?
      var gender: Gender?
      var yearBirth: Int?
      var photo: UIImage?
   }
   
   weak var tableView: UITableView!
   var user: UserModel?
   var password: String?
   
   func registerNewUser(_ data: RegisterData) {

      guard let email = data.email, email.isValidEmail() else {
         Alert.default.showOk("", message: "Please enter your email address".localized)
         return
      }
      guard let password = data.password, password.count > 6 else {
         Alert.default.showOk("", message: "Please enter password (more than 6 characters)".localized)
         return
      }
      guard let name = data.name, name.isEmpty == false else {
         Alert.default.showOk("", message: "Please enter name".localized)
         return
      }
      guard let image = data.photo else {
         Alert.default.showOk("", message: "Please add photo".localized)
         return
      }
      let address = data.address ?? ""
      let gender = data.gender ?? .both
      let yearBirth = data.yearBirth ?? -1
      
      print("\(name), \(email), \(password), \(address), \(gender.description) \(yearBirth)")
      
//      UsersManager.signUp(name: name, email: email, password: password, address: address, gender: gender, yearbirth: yearBirth) { user in
         if let user = user {
            PhotosManager.uploadPhoto(image, for: user.userId) { success in
               if success == false {
                  Alert.default.showOk("We can't upload photo on our local server".localized, message: "Please try it later".localized)
               }
            }
            presentMainScreen()
         } else {
            Alert.default.showOk("We can't register your profile".localized, message: "Please check your email address".localized)
         }
//      }

   }
}
