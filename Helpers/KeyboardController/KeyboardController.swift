//
//  KeyboardController.swift
//  eMia
//
//  Created by Sergey Krotkih on 05/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KeyboardController: AnyObservable {
   
   var observers: [Any] = []
   weak private var parentView: UIView?
   private var screenView: UIView!
   private var disposeBag = DisposeBag()
   
   var screenPresented = PublishSubject<Bool>()
   
   func configure(with parentView: UIView) {
      configureScreen(wiyh: parentView)
      registerObserver()
   }
   
   deinit {
      unregisterObserver()
      Log()
   }
   
   private func configureScreen(wiyh parentView: UIView) {
      self.parentView = parentView
      self.screenView = UIView(frame: parentView.bounds)
      screenView.backgroundColor = UIColor.clear
      let tapGesture = UITapGestureRecognizer()
      self.screenView.addGestureRecognizer(tapGesture)
      tapGesture.rx.event.bind { [weak self] _ in
         guard let `self` = self else { return }
         self.parentView?.endEditing(true)
         }.disposed(by: disposeBag)
   }
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      observers.append(
         _ = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardWillShow()
         }
      )
      observers.append(
         _ = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardWillHide()
         }
      )
   }
   
   private func keyboardWillShow() {
      guard let parentView = self.parentView else {
         return
      }
      parentView.addSubview(screenView)
      screenPresented.onNext(true)
   }
   
   private func keyboardWillHide() {
      screenView.removeFromSuperview()
      screenPresented.onNext(false)
   }
}
