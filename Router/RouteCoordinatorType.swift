//
//  RouteCoordinatorType.swift
//  eMia
//

import UIKit
import RxSwift

protocol RouteCoordinatorType {
  init(window: UIWindow)

  /// transition to another scene
  @discardableResult
  func transition(to scene: Route, type: RouteTransitionType) -> Observable<Void>

  /// pop scene from navigation stack or dismiss current modal
  @discardableResult
  func pop(animated: Bool) -> Observable<Void>
}

extension RouteCoordinatorType {
  @discardableResult
  func pop() -> Observable<Void> {
    return pop(animated: true)
  }
}
