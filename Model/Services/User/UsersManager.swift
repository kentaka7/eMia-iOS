//
//  UsersManagerImpl.swift
//  eMia
//

import UIKit
import RealmSwift
import RxSwift
import RxRealm

internal let gUsersManager = UsersManagerImpl.default

class UsersManagerImpl: NSObject {
   
   static let `default` = UsersManagerImpl()
   
   private override init() {
      super.init()
   }

   private var lastUser: UserModel?
   var admin: UserModel?
   
   var currentUser: UserModel? {
      willSet(newValue) {
         lastUser = currentUser
      }
      didSet {
         NotificationCenter.default.post(name: Notification.Name(Notifications.ChangeData.CurrentUser), object: lastUser)
      }
   }
   
   func logOut() {
      UserDefaults.standard.removeObject(forKey: UserDefaultsKey.initUserEmailKey)
      UserDefaults.standard.removeObject(forKey: UserDefaultsKey.initUserPasswordKey)
      self.currentUser = nil
      _ = AppDelegate.instance.appRouter.transition(to: Route.login, type: .root)
   }

   func getAllUsers() -> [UserModel] {
      return LocalBaseController().users
   }

   func getUserWith(id userId: String) -> UserModel? {
      return getAllUsers().first(where: { (userModel) -> Bool in
         return userModel.userId == userId
      })
   }
   
   func userExists(_ userId: String) -> Bool {
      return getUserWith(id: userId) != nil
   }
   
   func searchUserBy(email: String) -> UserModel? {
      return getAllUsers().filter { $0.email.lowercased() == email.lowercased() }.first
   }
}

// MARK: - Update users data on the Server side

extension UsersManagerImpl {

   func registerUser(_ user: UserModel, completion: @escaping (UserModel?) -> Void) {
      updateUser(user) { granted in
         if granted {
            completion(user)
         } else {
            completion(nil)
         }
      }
   }
   
   func removeCurrentUser(completion: @escaping () -> Void) {
      guard let currentUser = self.currentUser else {
         completion()
         return
      }
      if let user = self.getUserWith(id: currentUser.userId) {
         self.deleteUser(user) {
            completion()
         }
      } else {
         completion()
      }
   }

   private func updateUser(_ user: UserModel, completion: @escaping (Bool) -> Void) {
      user.synchronize(completion: completion)
   }
   
   private func deleteUser(_ user: UserModel, completion: @escaping () -> Void) {
      let userItem = UserItem(user)
      userItem.remove()
      gPhotosManager.removeAvatar(user: user) { _ in
         completion()
      }
   }
}
