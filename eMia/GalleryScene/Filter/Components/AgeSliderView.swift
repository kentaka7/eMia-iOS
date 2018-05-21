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
   
   var minAgeFilter = Variable<Int>(0)
   var maxAgeFilter = Variable<Int>(0)
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
      let sliderView = Bundle.main.loadNibNamed("AgeSliderView", owner: nil, options: nil)![0] as! AgeSliderView
      sliderView.frame = superView.bounds
      sliderView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      superView.addSubview(sliderView)
      sliderView.configureSlider(min: min, max: max)
      sliderView.subscribeObChanged()
      return sliderView
   }
   
   private func configureSlider(min: Int, max: Int) {
      rangeSlider.backgroundColor = UIColor.clear
      rangeSlider.setMinValue(CGFloat(min), maxValue: CGFloat(max))
      rangeSlider.minimumDistance = 4
      rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
   }
   
   private func subscribeObChanged() {
      _ = minAgeFilter.asObservable().subscribe() { [weak self] minAge in
         guard let `self` = self else { return }
         self.showRange()
         }.disposed(by: disposeBug)
      _ = maxAgeFilter.asObservable().subscribe() { [weak self] maxAge in
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
      minAgeFilter.value = Int(rangeSlider.leftValue)
      maxAgeFilter.value = Int(rangeSlider.rightValue)
   }
}
