//
//  MyProfileInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyProfileInteractor: NSObject {
   
   struct MyProfileData {
      var name: String?
      var address: String?
      var gender: Gender?
      var yearBirth: Int?
      var photo: UIImage?
   }
   
   var loginInteractor: LoginInteractor!
   weak var tableView: UITableView!
   weak var activityIndicator: NVActivityIndicatorView!

   var user: UserModel!
   var password: String!
   var registerUser: Bool = false
   
   func updateMyProfile(_ data: MyProfileData, completed: @escaping () -> Void) {

      guard let name = data.name, name.isEmpty == false else {
         Alert.default.showOk("", message: "Please enter your name".localized)
         return
      }
      guard let image = data.photo else {
         Alert.default.showOk("", message: "Please add photo".localized)
         return
      }
      DataModelInteractor.saveWithRealm {
         user.name = name
         user.address = data.address ?? ""
         user.gender = data.gender
         user.yearbirth = data.yearBirth ?? -1
      }
      if self.registerUser {
         registerNewUser(with: image, completed: completed)
      } else {
         updateUserData(with: image, completed: completed)
      }
   }
   
   private func registerNewUser(with photo: UIImage, completed: @escaping () -> Void) {
      DataModelInteractor.saveWithRealm {
         user.tokenIOS = gDeviceTokenController.myDeviceTokens.first
      }
      self.activityIndicator.startAnimating()
      loginInteractor.signUp(user: self.user, password: self.password) { [weak self] user in
         guard let `self` = self else { return }
         self.activityIndicator.stopAnimating()
         if let user = user {
            let avatarFileName = user.userId
            self.activityIndicator.startAnimating()
            gPhotosManager.uploadPhoto(photo, for: avatarFileName) { success in
               self.activityIndicator.stopAnimating()
               if success {
                  completed()
               } else {
                  Alert.default.showOk("We can't upload photo on server".localized, message: "Please try it later".localized)
               }
            }
         } else {
            Alert.default.showOk("We can't register your profile".localized, message: "Please check your email address".localized)
         }
      }
   }
   
   private func updateUserData(with photo: UIImage, completed: @escaping () -> Void) {
      self.activityIndicator.startAnimating()
      self.user.synchronize { [weak self] success in
         guard let `self` = self else { return }
         self.activityIndicator.stopAnimating()
         if success {
            let avatarFileName = self.user.userId
            self.activityIndicator.startAnimating()
            gPhotosManager.uploadPhoto(photo, for: avatarFileName) { success in
               self.activityIndicator.stopAnimating()
               if success {
                  gPhotosManager.cleanPhotoCache(for: self.user)
                  completed()
               } else {
                  Alert.default.showOk("We can't upload photo on server".localized, message: "Please try it later".localized)
               }
            }
         } else {
            Alert.default.showOk("We can't save data".localized, message: "Please try it later".localized)
         }
      }
   }
}
