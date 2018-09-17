//
//  AppShortcuts.swift
//  eMia
//
//  Created by Sergey Krotkih on 07/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

// MARK: - 3D touch on the app home screen icon handler

struct AppShortcuts {
   
   static let shortcutItems: [UIApplicationShortcutItem] = [.createpost, .customersitelink, .aboutus]
   
   static func handleAction(for shortcutItem: UIApplicationShortcutItem) -> Bool {
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
   
   static func gotoCustomerSite() {
      if let url = URL(string: "http://www.coded.dk") {
         UIApplication.shared.open(url, options: [:])
      }
   }
   
   static func gotoOurSite() {
      if let url = URL(string: "http://www.coded.dk") {
         UIApplication.shared.open(url, options: [:])
      }
   }
   
   static func createNewPost() {
   }
}
