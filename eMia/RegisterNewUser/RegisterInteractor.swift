//
//  RegisterInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class RegisterInteractor: NSObject {
   
   weak var tableView: UITableView!
   var user: UserModel?
   var password: String?
   
   func registerNewUser() {
      
      let emailCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Email.rawValue, section: 0)) as! Register1ViewCell
      let passwordCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Password.rawValue, section: 0)) as! Register2ViewCell
      let nameCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Name.rawValue, section: 0)) as! Register7ViewCell
      let genderCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Gender.rawValue, section: 0)) as! Register4ViewCell
      let yearBirthCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.YearBirth.rawValue, section: 0)) as! Register5ViewCell
      let photoCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Photo.rawValue, section: 0)) as! Register6ViewCell
      let addressCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Address.rawValue, section: 0)) as! Register3ViewCell
      
      guard let email = emailCell.email, email.isValidEmail() else {
         Alert.default.showOk("", message: "Please enter your email address".localized)
         return
      }
      guard let password = passwordCell.password, password.count > 6 else {
         Alert.default.showOk("", message: "Please enter password (more than 6 characters)".localized)
         return
      }
      guard let name = nameCell.name, name.isEmpty == false else {
         Alert.default.showOk("", message: "Please enter name".localized)
         return
      }
      guard let image = photoCell.photo else {
         Alert.default.showOk("", message: "Please add photo".localized)
         return
      }
      let address = addressCell.address ?? ""
      let gender = genderCell.gender
      let yearBirth = yearBirthCell.yearBirth ?? -1
      
      print("\(name), \(email), \(password), \(address), \(gender), \(yearBirth)")
      
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
