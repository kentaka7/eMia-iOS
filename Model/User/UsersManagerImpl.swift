//
//  gUsersManager.swift
//  eMia
//

import UIKit
import RxSwift

protocol UsersPresenterModel: class {
   var currentUser: UserModel? {get}
   func getAllUsers(completion: @escaping ([UserModel]) -> Void)
   func logOut()
}

protocol UserDataObservable {
   func addObserver(users: [UserModel], closure: @escaping UserObserverClosure)
   func removeObserver(users: [UserModel])
}

/// Singleton instance for Users tracker
internal let gUsersManager = UsersManagerImpl.sharedInstance

class UsersManagerImpl: NSObject {
   
   static let sharedInstance: UsersManagerImpl = {
      return AppDelegate.instance.usersDataBaseInteractor
   }()

   private var userObserver = UserObserver()
   private var lastUser: UserModel?
   
   private let disposeBag = DisposeBag()
   
   var admin: UserModel?

   var currentUser: UserModel? {
      willSet(newValue) {
         lastUser = currentUser
         if newValue == nil {
            // Log Out
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.initUserEmailKey)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.initUserPasswordKey)
         }
      }
      didSet {
         NotificationCenter.default.post(name: Notification.Name(Notifications.ChangeData.CurrentUser), object: lastUser)
      }
   }

   override init() {
      super.init()
   }
   
   deinit {
   }
   
   func loadData(completion: ([UserModel]) -> Void) {
      completion(UserModel.users)
   }
   
   // MARK: 
   
   func getUserWith(id userId: String) -> UserModel? {
      let users = UserModel.users
      if let index = users.index(where: {$0.userId == userId}) {
         let user = users[index]
         return user
      } else {
         return nil
      }
   }
   
   func userExists(_ userId: String) -> Bool {
      return getUserWith(id: userId) != nil
   }
   
   fileprivate func changeCurrentUserDataIfNeeded() {
      guard let currentUser = self.currentUser else {
         return
      }
      if let user = getUserWith(id: currentUser.userId) {
         currentUser.copy(user)
      }
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
   
   func updateUser(_ user: UserModel, completion: @escaping (Bool) -> Void) {
      let userItem = UserItem(user: user)
      userItem.synchronize(completion: completion)
   }
   
   fileprivate func deleteUser(_ user: UserModel, completion: @escaping () -> Void) {
      let userItem = UserItem(user: user)
      userItem.remove()
      gPhotosManager.removeAvatar(user: user) { _ in
         completion()
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
}

// MARK: - UsersPresenterModel

extension UsersManagerImpl: UsersPresenterModel {

   func getAllUsers(completion: @escaping ([UserModel]) -> Void) {
      self.loadData(completion: completion)
   }
   
   private func signOut() {
      self.currentUser = nil
   }

   func logOut() {
      self.signOut()
      _ = AppDelegate.instance.appRouter.transition(to: Route.login, type: .root)
   }
}

// MARK: - UserDataObservable protocol implementation

extension UsersManagerImpl: UserDataObservable {
   
   func addObserver(users: [UserModel], closure: @escaping UserObserverClosure) {
      userObserver.addObserver(users: users, closure: closure)
   }
   
   func removeObserver(users: [UserModel]) {
      userObserver.removeObservers(users)
   }
}
