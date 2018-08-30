//
//  MyProfileInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RealmSwift
import RxRealm

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
   var registrationNewUser: Bool = false
   
   func updateMyProfile(_ image: UIImage, completed: @escaping () -> Void) {
      if self.registrationNewUser {
         registerNewUser(with: image, completed: completed)
      } else {
         updateUserData(with: image, completed: completed)
      }
   }
   
   private func registerNewUser(with photo: UIImage, completed: @escaping () -> Void) {
      _ = Realm.update {
         user.tokenIOS = gDeviceTokenController.currentDeviceToken
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
            Alert.default.showOk("We can't register your profile".localized, message: "Please check your email address and try it again".localized)
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
