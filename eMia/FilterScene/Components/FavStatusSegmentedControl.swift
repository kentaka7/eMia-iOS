//
//  FavStatusSegmentedControl.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavStatusSegmentedControl: UIView {
   
    @IBOutlet weak var selectedAllView: UIView!
    @IBOutlet weak var selectedMyFavoriteView: UIView!
    
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var myFavoriteLabel: UILabel!

   @IBOutlet var tapAllRecognizer: UITapGestureRecognizer!
   @IBOutlet var tapMyFavoriteRecognizer: UITapGestureRecognizer!
   
   private var labelsColor: UIColor!
   
   var favoriteFilter = BehaviorSubject<FilterFavorite>(value: .none)
   private let disposeBug = DisposeBag()
   
   fileprivate struct Constants {
      static let cornerRadius: CGFloat = 3.0
      static let borderWidth: CGFloat = 2.0
   }

   static func getInstance(for superView: UIView) -> FavStatusSegmentedControl {
      if let view = UIView.loadFrom(nibNamed: "FavStatusSegmentedControl") as? FavStatusSegmentedControl {
         view.frame = superView.bounds
         view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
         superView.addSubview(view)
         return view
      } else {
         assert(false, "FavStatusSegmentedControl is not defined!")
         return FavStatusSegmentedControl()
      }
   }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      configureView()
      setUpLocalObserver()
   }
   
   private func configureView() {
      allLabel.text = "All".localized
      myFavoriteLabel.text = "My Favorities".localized
      
      selectedAllView.layer.borderColor = UIColor.clear.cgColor
      selectedAllView.layer.cornerRadius = Constants.cornerRadius
      selectedAllView.layer.borderWidth = Constants.borderWidth

      selectedMyFavoriteView.layer.borderColor = UIColor.clear.cgColor
      selectedMyFavoriteView.layer.cornerRadius = Constants.cornerRadius
      selectedMyFavoriteView.layer.borderWidth = Constants.borderWidth
      
      labelsColor = allLabel.textColor
      
      tapAllRecognizer.rx.event.subscribe({[weak self] _ in
         guard let `self` = self else { return }
         self.favoriteFilter.onNext(.all)
      }).disposed(by: disposeBug)

      tapMyFavoriteRecognizer.rx.event.subscribe({[weak self] _ in
         guard let `self` = self else { return }
         self.favoriteFilter.onNext(.myFavorite)
      }).disposed(by: disposeBug)
   }
   
   private func setUpLocalObserver() {
      _ = favoriteFilter.asObservable().subscribe { [weak self] favStatus in
         guard let `self` = self else { return }
         guard let status = favStatus.element else {
            return
         }
         self.allLabel.textColor = self.labelsColor
         self.allLabel.font = GlobalFonts.kAvenirBook
         self.myFavoriteLabel.textColor = self.labelsColor
         self.myFavoriteLabel.font = GlobalFonts.kAvenirBook

         switch status {
         case .none:
            return
         case .all:
            self.allLabel.textColor = GlobalColors.kBrandNavBarColor
            self.allLabel.font = GlobalFonts.kAvenirBold
            self.selectedAllView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
         case .myFavorite:
            self.myFavoriteLabel.textColor = GlobalColors.kBrandNavBarColor
            self.myFavoriteLabel.font = GlobalFonts.kAvenirBold
            self.selectedMyFavoriteView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
         }
      }
   }
}
