//
//  MyProfileInteractor.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RxSwift
import RealmSwift
import RxRealm

struct MyProfileData {
   var name: String
   var address: String
   var gender: Gender
   var yearBirth: Int
   var photo: UIImage
}

class MyProfileInteractor: MyProfileInteractorProtocol {
   
   // Strong Dependencies
   var loginWorker: MyProfileLoginWorkerProotocol!
   
   // Weak Dependencies
   weak var tableView: UITableView!
   weak var activityIndicator: NVActivityIndicatorView!
   weak var input: MyProfileInteractorInput!
   
   weak var user: UserModel!
   
   private let disposeBag = DisposeBag()
   
   var password: String!
   var registrationNewUser: Bool {
      return user.userId.isEmpty
   }

   deinit {
      Log()
   }

   func saveData(_ completion: @escaping () -> Void) {
      guard let data = input.myProfileData() else {
         return
      }
      self.updateProfile(for: data) {
         completion()
      }
   }
}

// MARK: - Private methods

extension MyProfileInteractor {
   
   private func updateProfile(for data: MyProfileData, completed: @escaping () -> Void) {
      Realm.update {
         user.name = data.name
         user.gender = data.gender
         user.yearbirth = data.yearBirth
         user.address = data.address
         }.subscribe(onNext: { _ in
            self.goToNextView(for: data, completed)
         }, onError: { error in
            print(error.localizedDescription)
            if let error = error as? RealmOperationsError {
               Alert.default.showError(message: error.description())
            }
         }).disposed(by: disposeBag)
   }
   
   private func goToNextView(for data: MyProfileData, _ completed: @escaping () -> Void) {
      if self.registrationNewUser {
         registerNewUser(with: data.photo, completed: completed)
      } else {
         updateUserData(with: data.photo, completed: completed)
      }
   }
   
   private func registerNewUser(with photo: UIImage, completed: @escaping () -> Void) {
      Realm.update {
         user.tokenIOS = gDeviceTokenController.currentDeviceToken
      }
      self.activityIndicator.startAnimating()
      loginWorker.signUp(user: self.user, password: self.password) { [weak self] user in
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
                  Alert.default.showOk("Fail while uploading the photo to our server!".localized, message: "Please try it later again".localized)
               }
            }
         } else {
            Alert.default.showOk("Fail while uploading data to our server!".localized, message: "Please try it later again".localized)
         }
      }
   }
}
