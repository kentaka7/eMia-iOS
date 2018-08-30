//
//  Constants.swift
//  eMia
//

import UIKit

// MARK: -

struct Notifications {
   
   struct Application {
      static let WillEnterForeground = "WillEnterForeground"
      static let DidBecomeActive = "DidBecomeActive"
      static let WillResignActive = "WillResignActive"
      static let DidEnterBackground = "DidEnterBackground"
   }
   
   struct ChangeData {
      static let UsersDataBase = "UsersDataBaseChanged"
      static let PostsDataBase = "RequestDataBaseChanged"
      static let CommentsDataBase = "AvatarDataBaseChanged"
      static let CurrentUser = "CurrentUserChanged"
   }
   
   static let WillEnterMainScreen = "WillEnterMainScreen"
   
   static let UpdatedFilter = "UpdatedFilter"
}

struct UserDefaultsKey {
   static let initUserEmailKey = "userEmail"
   static let initUserPasswordKey = "userPassword"
   static let kDeviceTokens = "DeviceTokens"
}

// MARK: - Default database name

struct DefaultDataBase {
   static let name = "main"
}

struct Firebase {
   static let ServerKey = "AIzaSyBwlP3fkou4NhVa6k_a7EMazGBZHDCXCw0"
   static let StorageURL = "gs://boblberg-b8a0f.appspot.com"

//   static let ServerKey = "AIzaSyBKtQxK_qNS-hj6Nio_PyOQ55v4wu5WhCw"
//   static let StorageURL = "gs://emia-885b7.appspot.com"

   static let PushNotificationUrl = "https://fcm.googleapis.com/fcm/send"
}

struct AppConstants {
   static let SizeAvatarImage = 72.0
   static let ApplicationName = "eMia"
   static let ManufacturingName = "dk.coded"
}

struct Settings {
   static let separator = ","
   static let tokenStoreKey = "CurrentDeviceToken"
}

struct Platform {
   
   static var isSimulator: Bool {
      return TARGET_OS_SIMULATOR != 0
   }
   
}
