//
//  AppLifecycleMediator.swift
//  eMia
//
//  Created by Сергей Кротких on 07/09/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

// MARK: - AppLifecycleListener

protocol AppLifecycleListener {
   func onAppWillEnterForeground()
   func onAppDidEnterBackground()
   func onAppDidFinishLaunching()
}

// MARK: - Mediator

class AppLifecycleMediator: NSObject, AnyObservable {
   
  var observers: [Any] = []
   
   static var defaultInstance: AppLifecycleMediator!
   
   static func makeDefaultMediator() {
      let listener1 = DefaultAppLifeListener()
      self.defaultInstance = AppLifecycleMediator(listeners: [listener1])
   }
   
   private let listeners: [AppLifecycleListener]
   
   init(listeners: [AppLifecycleListener]) {
      self.listeners = listeners
      super.init()
      registerObserver()
   }
   
   deinit {
      unregisterObserver()
   }
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      observers.append(
         _ = center.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.onAppWillEnterForeground()
         }
      )
      observers.append(
         _ = center.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.onAppDidEnterBackground()
         }
      )
      observers.append(
         _ = center.addObserver(forName: .UIApplicationDidFinishLaunching, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.onAppDidFinishLaunching()
         }
      )
   }
   
   private func onAppWillEnterForeground() {
      listeners.forEach { $0.onAppWillEnterForeground() }
   }
   
   private func onAppDidEnterBackground() {
      listeners.forEach { $0.onAppDidEnterBackground() }
   }
   
   private func onAppDidFinishLaunching() {
      listeners.forEach { $0.onAppDidFinishLaunching() }
   }
}

// MARK: - Default App Lifecycle listener

class DefaultAppLifeListener: AppLifecycleListener {
   
   func onAppWillEnterForeground() {
      Log()
   }
   
   func onAppDidEnterBackground() {
      Log()
   }

   func onAppDidFinishLaunching() {
      Log()
   }
}
