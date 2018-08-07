//
//  FakeFieldController.swift
//  eMia
//
//  Created by Сергей Кротких on 06/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FakeFieldController: AnyObservable {
   
   var observers: [Any] = []
   weak private var parentView: UIView?
   weak private var anchorView: UIView?
   private var textField: UITextField?
   private var disposeBag = DisposeBag()
   
   func configure(with parentView: UIView, anchorView: UIView) {
      self.parentView = parentView
      self.anchorView = anchorView
      if self.textField == nil {
         textField = UITextField(frame: CGRect(x: 0, y: 0, width: 5, height: 17))
         textField?.text = ""
         parentView.addSubview(textField!)
      }
      registerObserver()
   }
   
   deinit {
      unregisterObserver()
   }
   
   var focus: Bool {
      get {
         return self.textField!.isFirstResponder
      }
      set {
         if newValue {
            self.textField!.becomeFirstResponder()
         } else {
            self.textField!.resignFirstResponder()
         }
      }
   }
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      observers.append(
         _ = center.addObserver(forName: .UIKeyboardDidShow, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardDidShow()
         }
      )
      observers.append(
         _ = center.addObserver(forName: .UIKeyboardDidHide, object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else { return }
            self.keyboardDidHide()
         }
      )
   }
   
   private func keyboardDidShow() {
      guard let anchorView = self.anchorView, let parentView = self.parentView, let textField = self.textField else {
         return
      }
      let rect = anchorView.convert(anchorView.frame, to: parentView)
      var frame = textField.frame
      frame.origin.y = rect.minY + 8.0
      textField.frame = frame
   }
   
   private func keyboardDidHide() {

   }
}
