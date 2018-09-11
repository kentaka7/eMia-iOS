//
//  EditPost2ViewCell.swift
//  eMia
//

import UIKit

// Body text. variavle height table view cell!

class EditPost2ViewCell: UITableViewCell {

   @IBOutlet weak var bodyTextView: UITextView!

   override func awakeFromNib() {
      configureTextBody()
   }

   private func configureTextBody() {
      bodyTextView.translatesAutoresizingMaskIntoConstraints = false
      bodyTextView.isScrollEnabled = false
   }
}


extension EditPost2ViewCell {

   func setBody(_ text: String?) -> CGFloat {
      bodyTextView.text = text
      bodyTextView.sizeToFit()
      return bodyTextView.frame.height
   }
}
