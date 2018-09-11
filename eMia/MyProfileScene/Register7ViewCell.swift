//
//  Register7ViewCell.swift
//  eMia
//

import UIKit

/**
 MyProfile scene.
 User's Name definition
 */

protocol UserNameChangeable {
   var name: String? {get}
}

@IBDesignable class Register7ViewCell: UITableViewCell, UserNameChangeable {

   @IBOutlet weak var nameTitleLabel: UILabel!
   @IBOutlet weak var nameTextField: UITextField!

   @IBInspectable var borderColor: UIColor {
      set {
         self.layer.borderColor = newValue.cgColor
      }
      get {
         return UIColor(cgColor: self.layer.borderColor ?? UIColor.white.cgColor)
      }
   }
   
   @IBInspectable var borderWidth: Int {
      set {
         self.layer.borderWidth = CGFloat(newValue)
      } get {
         return Int(self.layer.borderWidth)
      }
   }
   
   var name: String? {
      return nameTextField.text
   }

   override func willMove(toSuperview newSuperview: UIView!) {
      configure()
   }
   
   override func awakeFromNib() {
      configure()
   }
   
   private  func configure() {
      nameTitleLabel.text = "Your Name".localized
      nameTitleLabel.textColor = GlobalColors.kBrandNavBarColor
   }
}

//

extension Register7ViewCell {
   
   func setTextField(text: String) {
      nameTextField.text = text
   }
}
