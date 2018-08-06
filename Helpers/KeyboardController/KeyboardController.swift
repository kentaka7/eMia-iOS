//
//  KeyboardController.swift
//  eMia
//
//  Created by Сергей Кротких on 05/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KeyboardController: AnyObservable {
   
   var observers: [Any] = []
   weak private var parentView: UIView?
   private var screenView: UIView!
   private var disposeBag = DisposeBag()
   
   func configure(with parentView: UIView) {
      self.parentView = parentView
      configureScreenView()
      registerObserver()
   }
   
   deinit {
      unregisterObserver()
   }
   
   private func configureScreenView() {
      guard let parentView = self.parentView else {
         return
      }
      self.screenView = UIView(frame: parentView.bounds)
      screenView.backgroundColor = UIColor.clear
      let tapGest = UITapGestureRecognizer()
      self.screenView.addGestureRecognizer(tapGest)
      tapGest.rx.event.bind { [weak self] _ in
         guard let `self` = self else { return }
         self.parentView?.endEditing(true)
         }.disposed(by: disposeBag)
   }
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      observers.append(
         _ = center.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardWillShow()
         }
      )
      observers.append(
         _ = center.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardWillHide()
         }
      )
   }
   
   private func keyboardWillShow() {
      parentView?.addSubview(screenView)
   }
   
   private func keyboardWillHide() {
      screenView?.removeFromSuperview()
   }
}
