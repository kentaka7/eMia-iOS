//
//  AppDelegate.swift
//  eMia
//

import UIKit
import Firebase
import UserNotifications
import IQKeyboardManagerSwift

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
   
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

      AppDelegate.instance = self
      
      setUpAppearance()
      
      self.application  = application
      
      gFireBaseAuth.configure()
      
      gDeviceTokenController.configure()
      
      application.shortcutItems = [.createpost, .customersitelink, .aboutus]
      
      Appearance.customize()
      
      IQKeyboardManager.shared.enable = true
      
      appRouter = RouteCoordinator(window: window!)
      appRouter.launchFirstScene()

      return true
   }
   
   func applicationWillEnterForeground(_ application: UIApplication) {
      NotificationCenter.default.post(name: Notification.Name(Notifications.Application.WillEnterForeground), object: nil)
   }
   
   func applicationDidBecomeActive(_ application: UIApplication) {
      NotificationCenter.default.post(name: Notification.Name(Notifications.Application.DidBecomeActive), object: nil)
   }
   
   func applicationWillResignActive(_ application: UIApplication) {
      NotificationCenter.default.post(name: Notification.Name(Notifications.Application.WillResignActive), object: nil)
   }
   
   func applicationDidEnterBackground(_ application: UIApplication) {
      NotificationCenter.default.post(name: Notification.Name(Notifications.Application.DidEnterBackground), object: nil)
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
      completionHandler(handleAction(for: shortcutItem))
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

// MARK: - 3D touch on the app home screen icon handler

extension AppDelegate {

   func handleAction(for shortcutItem: UIApplicationShortcutItem) -> Bool {
      if shortcutItem == .createpost {
         createNewPost()
         return true
      } else if shortcutItem == .customersitelink {
         gotoCustomerSite()
         return true
      } else if shortcutItem == .aboutus {
         gotoOurSite()
         return true
      } else {
         return false
      }
   }
   
   func gotoCustomerSite() {
      if let url = URL(string: "http://www.coded.dk") {
         UIApplication.shared.open(url, options: [:])
      }
   }
   
   func gotoOurSite() {
      if let url = URL(string: "http://www.coded.dk") {
         UIApplication.shared.open(url, options: [:])
      }
   }
   
   func createNewPost() {
   }
}

// MARK: Appearence

extension AppDelegate {
   private func setUpAppearance() {
      UINavigationBar.appearance().barTintColor = GlobalColors.kBrandNavBarColor
      UINavigationBar.appearance().tintColor = GlobalColors.kBrandNavBarColor
      UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

   }
   
}
