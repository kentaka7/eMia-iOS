//
//  DeviceTokenController.swift
//  eMia
//
import Foundation
import Firebase
import RealmSwift
import RxSwift
import RxRealm

internal let gDeviceTokenController = DeviceTokenControllerImpl.default

class DeviceTokenControllerImpl: NSObject, AnyObservable {
   
   static let `default` = DeviceTokenControllerImpl()
   
   private override init() {
      super.init()
   }
   
   var observers = [Any] ()
   
   deinit {
      unregisterObserver()
   }
   
   /// Device token, if Firebase is used then we store `fcmToken`
   fileprivate var deviceToken: String? {
      return  Messaging.messaging().fcmToken
   }
   
   func configure() {
      Messaging.messaging().delegate = self
      registerObserver()
   }
   
   func registerObserver() {
      let queue = OperationQueue.main
      observers.append(
         _ = NotificationCenter.default.addObserver(forName: Notification.Name(Notifications.ChangeData.CurrentUser), object: nil, queue: queue) { _ in
            self.addDeviceTokenToCurrentUser()
         }
      )
   }
   
   fileprivate func addDeviceTokenToCurrentUser() {
      guard let token = self.deviceToken, !token.isEmpty else {
         return
      }
      guard let currentUser = gUsersManager.currentUser else {
         return
      }
      self.userDefaultDeviceTokenUpdate(for: token)
      self.iOSTokens(for: currentUser) { tokens in
         if tokens.index(of: token) != nil {
            return
         }
         var tokens = tokens
         tokens.append(token)
         self.synchronize(tokens, for: currentUser) { _ in }
      }

   }
   
   private func synchronize(_ tokens: [String], for user: UserModel, completion: @escaping (Bool) -> Void) {
      let tokensIOSValues = tokens.joined(separator: Settings.separator)
      DataBaseImpl.saveWithRealm {
         user.tokenIOS = tokensIOSValues
      }
      user.synchronize { success in
         completion(success)
      }
   }
   
   private func userDefaultDeviceTokenUpdate(for decviceToken: String) {
      var tokens = myDeviceTokens
      if tokens.index(of: decviceToken) != nil {
         return
      }
      tokens.append(decviceToken)
      let data = NSKeyedArchiver.archivedData(withRootObject: tokens)
      UserDefaults.standard.set(data, forKey: UserDefaultsKey.kDeviceTokens)
      UserDefaults.standard.synchronize()
   }
   
   private var myDeviceTokens: [String] {
      if let data = UserDefaults.standard.object(forKey: UserDefaultsKey.kDeviceTokens) as? Data {
         if let myDeviceTokens = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] {
            return myDeviceTokens
         }
      }
      return []
   }
   
   var currentDeviceToken: String? {
      return myDeviceTokens.first
   }
   
   func acceptedToken(_ token: String) -> Bool {
      return myDeviceTokens.index(where: {$0 == token}) == nil
   }
   
   func removeDeviceTokens(for user: UserModel, completion: @escaping (String) -> Void) {
      let myTokens = self.myDeviceTokens
      self.iOSTokens(for: user) { currentTokens in
         var currentTokens = currentTokens
         for token in myTokens {
            if let index = currentTokens.index(of: token) {
               currentTokens.remove(at: index)
            }
         }
         let tokensIOSValues = currentTokens.joined(separator: Settings.separator)
         completion(tokensIOSValues)
      }
   }
}

// MARK: - Messaging Delegate

extension DeviceTokenControllerImpl: MessagingDelegate {
   
   func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print(#function)
      addDeviceTokenToCurrentUser()
   }
}

// MARK: - AppDelegate protocol

extension DeviceTokenControllerImpl {
   
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      DispatchQueue.main.async {
         Messaging.messaging().apnsToken = deviceToken
         self.addDeviceTokenToCurrentUser()
      }
      output(deviceToken: deviceToken)
   }
   
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("\(#function) Registration failed!")
   }
   
   private func output(deviceToken: Data) {
      var token = ""
      for tokenItem in deviceToken {
         token += String(format: "%02.2hhx", arguments: [tokenItem])
      }
      print("Registration succeeded! Token: ", token)
      let fcmToken = Messaging.messaging().fcmToken
      print("fcmToken", fcmToken ?? "NaN" )
   }
}

// MARK: - Current DEvice Tokens

extension DeviceTokenControllerImpl {
   
   func iOSTokens(for user: UserModel, _ completion: @escaping ([String]) -> Void) {
      userDeviceTokens(for: user, fieldName: UserFields.tokenIOS, completion: completion)
   }
   
   /// List of user device tokens
   func androidTokens(for user: UserModel, _ completion: @escaping ([String]) -> Void) {
      userDeviceTokens(for: user, fieldName: UserFields.tokenAndroid, completion: completion)
   }
   
   private func userDeviceTokens(for user: UserModel, fieldName: String, completion: @escaping ([String]) -> Void) {
      gDataBaseRef.child(UserFields.users).child(user.userId).child(fieldName).observeSingleEvent(of: .value, with: { snapshot in
         if snapshot.exists() {
            if let tokens = snapshot.value as? String {
               var newDeviceTokens = [String]()
               let deviceTokens = tokens.components(separatedBy: Settings.separator)
               for token in deviceTokens where token.count > 10 {
                  newDeviceTokens.append(token)
               }
               completion(newDeviceTokens)
            } else {
               completion([])
            }
         } else {
            completion([])
         }
      })
   }
}
