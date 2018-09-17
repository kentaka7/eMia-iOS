//
//  AppDelegateCommands.swift
//  eMia
//
//  Created by Sergey Krotkih on 07/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

protocol Command {
   func execute()
}

struct StartNetworkMonitoringCommand: Command {
   func execute() {
      gNetwork.startMonitoring()
   }
}

struct InitialViewControllerCommand: Command {
   let window: UIWindow
   
   func execute() {
      let appRouter = RouteCoordinator(window: window)
      appRouter.launchFirstScene()
      AppDelegate.instance.appRouter = appRouter
   }
}

struct FirebaseConfigureCommand: Command {
   func execute() {
      gFirebaseAuth.configure()
   }
}

struct DeviceTokenListenerCommand: Command {
   func execute() {
      gDeviceTokenController.configure()
   }
}

struct AppearenceCustomizeCommand: Command {
   func execute() {
      Appearance.customize()
   }
}

struct IQKeyboardCustomizeCommand: Command {
   func execute() {
      IQKeyboardManager.shared.enable = true
   }
}

struct AppLifecycleListenerCommand: Command {
   func execute() {
      AppLifecycleMediator.makeDefaultMediator()
   }
}

struct AppShortcutCustomizeCommand: Command {
   let application: UIApplication
   func execute() {
      application.shortcutItems = AppShortcuts.shortcutItems
   }
}

// MARK: - Builder

final class StartupCommandsBuilder {
   private var window: UIWindow!
   private var application: UIApplication!
   
   func setKeyWindow(_ window: UIWindow) -> StartupCommandsBuilder {
      self.window = window
      return self
   }
   
   func setApplication(_ application: UIApplication) -> StartupCommandsBuilder {
      self.application = application
      return self
   }
   
   func build() -> [Command] {
      return [
         StartNetworkMonitoringCommand(),
         FirebaseConfigureCommand(),
         DeviceTokenListenerCommand(),
         AppearenceCustomizeCommand(),
         IQKeyboardCustomizeCommand(),
         AppLifecycleListenerCommand(),
         AppShortcutCustomizeCommand(application: application),
         InitialViewControllerCommand(window: window)
      ]
   }
}

