//
//  LoginInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class LoginInteractor: NSObject {

   func reLogIn(_ completion: @escaping (Bool) -> Void) {
      let (initUserEmail, initUserPassword) = restoreCredentials()
      if let email = initUserEmail, let password = initUserPassword {
         self.signIn(email: email, password: password, completion: completion)
      } else {
         completion(false)
      }
   }
   
   func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
      gFirebaseAuth.signIn(email: email, password: password) { success in
         if success {
            self.save(email: email, password: password)
            self.getUserBy(email: email) { user in
               if let user = user {
                  gUsersManager.currentUser = user
                  completion(true)
               } else {
                  completion(false)
               }
            }
         } else {
            completion(false)
         }
      }
   }
   
   private func getUserBy(email: String, completion: @escaping (UserModel?) -> Void) {
      gFirebaseFetcher.downloadAllData {
         let user = gUsersManager.searchUserBy(email: email)
         completion(user)
      }
   }

   private func save(email: String, password: String) {
      UserDefaults.standard.set(email, forKey: UserDefaultsKey.initUserEmailKey)
      UserDefaults.standard.set(password, forKey: UserDefaultsKey.initUserPasswordKey)
   }
   
   private func restoreCredentials() -> (String?, String?) {
      let email = UserDefaults.standard.value(forKey: UserDefaultsKey.initUserEmailKey) as? String
      let password = UserDefaults.standard.value(forKey: UserDefaultsKey.initUserPasswordKey) as? String
      return (email, password)
   }
}

extension LoginInteractor: MyProfileLoginWorkerProotocol {
   
   func signUp(user: UserModel, password: String, completion: @escaping (UserModel?) -> Void) {
      let email = user.email
      gFirebaseAuth.signUp(email: email, password: password) { userId in
         guard let userId = userId else {
            Alert.default.showOk("Server error".localized, message: "Can't register you on our system!".localized)
            completion(nil)
            return
         }
         user.userId = userId
         self.save(email: email, password: password)
         self.getUserBy(email: email) { registeredUser in
            if let registeredUser = registeredUser {
               gUsersManager.currentUser = registeredUser
               completion(registeredUser)
            } else {
               gUsersManager.registerUser(user) { newUser in
                  if let newUser = newUser {
                     gUsersManager.currentUser = newUser
                     completion(newUser)
                  } else {
                     Alert.default.showOk("Server error".localized, message: "Can't register you on our system!".localized)
                     completion(nil)
                  }
               }
            }
         }
      }
   }
}

