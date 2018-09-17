//
//  AgeSlider.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AgeSliderView: UIView {
   
   @IBOutlet weak var rangeSlider: MARKRangeSlider!
   @IBOutlet weak var rangeLabel: UILabel!
   
   var minAgeFilter = BehaviorSubject<Int>(value: 0)
   var maxAgeFilter = BehaviorSubject<Int>(value: 0)
   private let disposeBag = DisposeBag()
   
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
         return AgeSliderView()
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
         }.disposed(by: disposeBag)
      _ = maxAgeFilter.asObservable().subscribe { [weak self] _ in
         guard let `self` = self else { return }
         self.showRange()
         }.disposed(by: disposeBag)
   }
   
   private func showRange() {
      do {
         let min: Int = try minAgeFilter.value()
         let max: Int = try maxAgeFilter.value()
         rangeLabel.text = "\(min) - \(max)"
      } catch {
      }
   }
   
   @objc private func rangeSliderValueChanged(_ sender: MARKRangeSlider) {
      minAgeFilter.onNext(Int(rangeSlider.leftValue))
      maxAgeFilter.onNext(Int(rangeSlider.rightValue))
   }
}
