//
//  RouteCoordinator.swift
//  eMia
//
//  Created by Sergey Krotkih on 2/7/18.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

func presentMainScreen() {
   AppDelegate.instance.appRouter.presentMainScreen()
}

class RouteCoordinator: RouteCoordinatorType {
   
   let loginInteractor = LoginInteractor()
   
   fileprivate var window: UIWindow
   fileprivate var currentViewController: UIViewController
   
   required init(window: UIWindow) {
      self.window = window
      currentViewController = window.rootViewController!
   }
   
   static func actualViewController(for viewController: UIViewController) -> UIViewController {
      if let navigationController = viewController as? UINavigationController {
         return navigationController.viewControllers.first!
      } else {
         return viewController
      }
   }
   
   @discardableResult
   func transition(to scene: Route, type: RouteTransitionType) -> Observable<Void> {
      let subject = PublishSubject<Void>()
      let viewController = scene.viewController()
      switch type {
      case .root:
         currentViewController = RouteCoordinator.actualViewController(for: viewController)
         window.rootViewController = viewController
         subject.onCompleted()
         
      case .push:
         guard let navigationController = currentViewController.navigationController else {
            fatalError("Can't push the view controller without navigation controller!")
         }
         // one-off subscription to be notified when push complete
         _ = navigationController.rx.delegate
            .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
            .map { _ in }
            .bind(to: subject)
         navigationController.pushViewController(viewController, animated: true)
         currentViewController = RouteCoordinator.actualViewController(for: viewController)
         
      case .modal:
         currentViewController.present(viewController, animated: true) {
            subject.onCompleted()
         }
         currentViewController = RouteCoordinator.actualViewController(for: viewController)
      }
      return subject.asObservable()
         .take(1)
   }
   
   @discardableResult
   func pop(animated: Bool) -> Observable<Void> {
      let subject = PublishSubject<Void>()
      if let presenter = currentViewController.presentingViewController {
         // dismiss a modal controller
         currentViewController.dismiss(animated: animated) {
            self.currentViewController = RouteCoordinator.actualViewController(for: presenter)
            subject.onCompleted()
         }
      } else if let navigationController = currentViewController.navigationController {
         // navigate up the stack
         // one-off subscription to be notified when pop complete
         _ = navigationController.rx.delegate
            .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
            .map { _ in }
            .bind(to: subject)
         guard navigationController.popViewController(animated: animated) != nil else {
            fatalError("can't navigate back from \(currentViewController)")
         }
         currentViewController = RouteCoordinator.actualViewController(for: navigationController.viewControllers.last!)
      } else {
         fatalError("Not a modal, no navigation controller: can't navigate back from \(currentViewController)")
      }
      return subject.asObservable()
         .take(1)
   }
}

extension RouteCoordinator {
   
   func launchFirstScene() {
      loginInteractor.reLogIn { success in
         if success {
            self.presentMainScreen()
         } else {
            DispatchQueue.main.async {
               _ = self.transition(to: Route.login, type: .root)
            }
         }
      }
   }
   
   func presentMainScreen() {
      NotificationCenter.default.post(name: Notification.Name(Notifications.WillEnterMainScreen), object: nil)
      runAfterDelay(0.5) {
         gPushNotificationsCenter.registerRemoteNotifications(for: AppDelegate.shared.application) { [weak self] in
            DispatchQueue.main.async {
               _ = self?.transition(to: Route.gallery, type: .root)
            }
         }
      }
   }
}
