//
//  gUsersManager.swift
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

   var users: [UserModel] {
      do {
         let realm = try Realm()
         let users = realm.objects(UserModel.self)
         return users.toArray()
      } catch _ {
         return []
      }
   }
   
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

   func getAllUsers(completion: @escaping ([UserModel]) -> Void) {
      completion(users)
   }

   func getUserWith(id userId: String) -> UserModel? {
      return users.filter {$0.userId == userId}.first
   }
   
   func userExists(_ userId: String) -> Bool {
      return getUserWith(id: userId) != nil
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
   
   private func updateUser(_ user: UserModel, completion: @escaping (Bool) -> Void) {
      let userItem = UserItem(user: user)
      userItem.synchronize(completion: completion)
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
   
   private func deleteUser(_ user: UserModel, completion: @escaping () -> Void) {
      let userItem = UserItem(user: user)
      userItem.remove()
      gPhotosManager.removeAvatar(user: user) { _ in
         completion()
      }
   }
}

extension UsersManagerImpl {
   
   func addUser(_ item: UserItem) {
      let model = UserModel(item: item)
      if model.userId.isEmpty == false {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   func deleteUser(_ item: UserItem) {
      let model = UserModel(item: item)
      if let index = usersIndex(of: model) {
         let model = self.users[index]
         Realm.delete(model: model)
      }
   }
   
   func editUser(_  item: UserItem) {
      self.addUser(item)
   }
   
   func usersIndex(of item: UserModel) -> Int? {
      return users.index(where: {$0 == item})
   }
   
}
