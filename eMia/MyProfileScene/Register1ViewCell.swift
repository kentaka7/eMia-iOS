//
//  Register1ViewCell.swift
//  eMia
//

import UIKit

protocol ForUserConfigurable {
   func configure(for user: UserModel)
}

/**
 MyProfile scene.
 User's email address definition
 */

@IBDesignable class Register1ViewCell: UITableViewCell, ForUserConfigurable {

   @IBOutlet weak var emailTitleLabel: UILabel!
   @IBOutlet weak var emailTextField: UITextField!
   
   var email: String? {
      return emailTextField.text
   }

   override func awakeFromNib() {
      configureView()
   }

   override func willMove(toSuperview newSuperview: UIView!) {
      configureView()
   }

   func configure(for user: UserModel) {
   }

   private func configureView() {
      emailTitleLabel.text = "Email".localized
      emailTitleLabel.textColor = GlobalColors.kBrandNavBarColor
   }
}
