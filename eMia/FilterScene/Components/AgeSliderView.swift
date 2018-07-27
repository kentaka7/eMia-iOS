//
//  AgeSlider.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AgeSliderView: UIView {
   
   @IBOutlet weak var rangeSlider: MARKRangeSlider!
   @IBOutlet weak var rangeLabel: UILabel!
   
   var minAgeFilter = BehaviorSubject<Int>(value: 0)
   var maxAgeFilter = BehaviorSubject<Int>(value: 0)
   private let disposeBug = DisposeBag()
   
   var minAge: CGFloat = 0.0 {
      didSet {
         rangeSlider.setLeftValue(minAge, rightValue: maxAge)
      }
   }
   
   var maxAge: CGFloat = 0.0 {
      didSet {
         rangeSlider.setLeftValue(minAge, rightValue: maxAge)
      }
   }
   
   static func getInstance(for superView: UIView, min: Int, max: Int) -> AgeSliderView {
      if let view = UIView.loadFrom(nibNamed: "AgeSliderView") as? AgeSliderView {
         view.frame = superView.bounds
         view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
         superView.addSubview(view)
         view.configureSlider(min: min, max: max)
         view.subscribeObChanged()
         return view
      } else {
         assert(false, "AgeSliderView is not defined!")
      }
   }
   
   private func configureSlider(min: Int, max: Int) {
      rangeSlider.backgroundColor = UIColor.clear
      rangeSlider.setMinValue(CGFloat(min), maxValue: CGFloat(max))
      rangeSlider.minimumDistance = 4
      rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
   }
   
   private func subscribeObChanged() {
      _ = minAgeFilter.asObservable().subscribe { [weak self] _ in
         guard let `self` = self else { return }
         self.showRange()
         }.disposed(by: disposeBug)
      _ = maxAgeFilter.asObservable().subscribe { [weak self] _ in
         guard let `self` = self else { return }
         self.showRange()
         }.disposed(by: disposeBug)
   }
   
   private func showRange() {
      let minAge = minAgeFilter.value
      let maxAge = maxAgeFilter.value
      rangeLabel.text = "\(minAge) - \(maxAge)"
   }
   
   @objc private func rangeSliderValueChanged(_ sender: MARKRangeSlider) {
      minAgeFilter.onNext(Int(rangeSlider.leftValue))
      maxAgeFilter.onNext(Int(rangeSlider.rightValue))
   }
}
