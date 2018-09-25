//
//  AppDelegate.swift
//  eMia
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
   static var instance: AppDelegate!
   var window: UIWindow?
   var shouldSupportAllOrientation = false
   var application: UIApplication!
   var appRouter: RouteCoordinator!
   
   static var shared: AppDelegate {
      guard let `self` = UIApplication.shared.delegate as? AppDelegate else {
         fatalError()
      }
      return self
   }
   
   var rootVC: UINavigationController {
      guard let navVC = self.window?.rootViewController as? UINavigationController else {
         fatalError()
      }
      return navVC
   }
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

      Log(message: String.getDocumentsPath())
      
      AppDelegate.instance = self
      self.application  = application
      
      StartupCommandsBuilder()
         .setKeyWindow(window!)
         .setApplication(application)
         .build()
         .forEach { $0.execute() }

      return true
   }
   
   // MARK: - Interface Orientation
   
   func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
      if shouldSupportAllOrientation == true {
         return UIInterfaceOrientationMask.all
      }
      return UIInterfaceOrientationMask.portrait
   }
   
   // MARK: - Open URL
   
   func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return true
   }
   
   // MARK: - 3D touch on the app home screen icon handler
   
   func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
      completionHandler(AppShortcuts.handleAction(for: shortcutItem))
   }
}

// MARK: - Push Notifications

extension AppDelegate {
   
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      gDeviceTokenController.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
   }
   
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      gDeviceTokenController.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
   }
   
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      gPushNotificationsCenter.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
   }
   
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      gPushNotificationsCenter.application(application, didReceiveRemoteNotification: userInfo)
   }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      gPushNotificationsCenter.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
   }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
      gPushNotificationsCenter.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
   }
}
