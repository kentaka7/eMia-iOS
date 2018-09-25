//
//  FakeFieldController.swift
//  eMia
//
//  Created by Sergey Krotkih on 06/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FakeFieldController: AnyObservable {
   
   var observers: [Any] = []
   weak private var parentView: UIView?
   weak private var anchorView: UIView?
   private var fakeField: UITextField?
   private var disposeBag = DisposeBag()
   
   func configure(with parentView: UIView, anchorView: UIView) {
      self.parentView = parentView
      self.anchorView = anchorView
      fakeField = UITextField(frame: CGRect(x: 0, y: 0, width: 5, height: 17))
      fakeField!.text = ""
      parentView.addSubview(fakeField!)
      registerObserver()
   }
   
   deinit {
      unregisterObserver()
      Log()
   }
   
   var focus: Bool {
      get {
         return self.fakeField?.isFirstResponder ?? false
      }
      set {
         if newValue {
            fakeField?.becomeFirstResponder()
         } else {
            fakeField?.resignFirstResponder()
         }
      }
   }
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      observers.append(
         _ = center.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardDidShow()
         }
      )
      observers.append(
         _ = center.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardDidHide()
         }
      )
   }
   
   private func keyboardDidShow() {
      guard let anchorView = self.anchorView,
         let parentView = self.parentView,
         let fakeField = self.fakeField else {
         return
      }
      let rect = anchorView.convert(anchorView.frame, to: parentView)
      var frame = fakeField.frame
      frame.origin.y = rect.minY + 8.0
      fakeField.frame = frame
   }
   
   private func keyboardDidHide() {
   }
}
