//
//  Register4ViewCell.swift
//  eMia
//

import UIKit
import RxSwift

// MyProfile scene: User's gender definition

class Register4ViewCell: UITableViewCell, ForUserConfigurable {

   @IBOutlet weak var imTitleLabel: UILabel!
   
   @IBOutlet weak var selectedGuyView: UIView!
   @IBOutlet weak var selectedGirlView: UIView!

   @IBOutlet weak var guyLabel: UILabel!
   @IBOutlet weak var girlLabel: UILabel!
   
   @IBOutlet weak var genderBackgroundView: UIView!

   fileprivate var labelsColor: UIColor!

   private var mGender: Gender?
   private let disposeBag = DisposeBag()
   
   var gender: Gender {
      get {
         return mGender ?? .boy
      }
      set {
         mGender = newValue
      }
   }

   func configure(for user: UserModel) {
      presentSelect(gender: user.gender ?? .boy)
   }
   
   override func awakeFromNib() {
      configure(imTitleLabel)
      configure(genderBackgroundView)
   }

   fileprivate func configure(_ view: UIView) {
      switch view {
      case imTitleLabel:
         imTitleLabel.text = "I'm"
         imTitleLabel.textColor = GlobalColors.kBrandNavBarColor
         
      case genderBackgroundView:
         labelsColor = guyLabel.textColor
         
         genderBackgroundView.layer.cornerRadius = 3.0
         genderBackgroundView.layer.borderWidth = 1.0
         genderBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
         
         let tapGesture1 = UITapGestureRecognizer()
         tapGesture1.rx.event.bind(onNext: { [weak self] recognizer in
            self?.selectedGuy()
         }).disposed(by: disposeBag)
         selectedGuyView.addGestureRecognizer(tapGesture1)

         selectedGuyView.layer.cornerRadius = 3.0
         selectedGuyView.layer.borderWidth = 2.0
         
         let tapGesture2 = UITapGestureRecognizer()
         tapGesture2.rx.event.bind(onNext: { [weak self] recognizer in
            self?.selectedGirl()
         }).disposed(by: disposeBag)
         selectedGirlView.addGestureRecognizer(tapGesture2)

         selectedGirlView.layer.cornerRadius = 3.0
         selectedGirlView.layer.borderWidth = 2.0
         
         presentSelect(gender: self.gender)
         
      default: break
      }
   }
   
   // MARK: Gender Selected Control
   
   private func selectedGuy() {
      didSelect(gender: .boy)
      presentSelect(gender: .boy)
   }
   
   private func selectedGirl() {
      didSelect(gender: .girl)
      presentSelect(gender: .girl)
   }
   
   func didSelect(gender: Gender) {
      self.gender = gender
   }
   
   func presentSelect(gender: Gender) {
      selectedGuyView.layer.borderColor = UIColor.clear.cgColor
      selectedGirlView.layer.borderColor = UIColor.clear.cgColor
      
      guyLabel.textColor = labelsColor
      guyLabel.font = GlobalFonts.kAvenirBook
      girlLabel.textColor = labelsColor
      girlLabel.font = GlobalFonts.kAvenirBook
      
      switch gender {
      case .none, .both:
         break
      case .boy:
         guyLabel.textColor = GlobalColors.kBrandNavBarColor
         guyLabel.font = GlobalFonts.kAvenirBold
         selectedGuyView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
      case .girl:
         girlLabel.textColor = GlobalColors.kBrandNavBarColor
         girlLabel.font = GlobalFonts.kAvenirBold
         selectedGirlView.layer.borderColor = GlobalColors.kBrandNavBarColor.cgColor
      }
   }
   
}
