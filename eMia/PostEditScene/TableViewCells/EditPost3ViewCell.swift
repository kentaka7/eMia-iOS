//
//  EditPost3ViewCell.swift
//  eMia
//

import UIKit

// Static text, Date, Send Email button

class EditPost3ViewCell: UITableViewCell {

   @IBOutlet weak var dateLabel: UILabel!
   @IBOutlet weak var commentLabel: UILabel!
   @IBOutlet weak var descriptionLabel: UILabel!
   @IBOutlet weak var sendEmailButtonView: UIView!
   
   override func awakeFromNib() {
      configureSendFeedbackButton()
   }

   private func configureSendFeedbackButton() {
      sendEmailButtonView.backgroundColor = GlobalColors.kBrandNavBarColor
   }
   
}


extension EditPost3ViewCell {

   func setCreated(_ text: String) {
      dateLabel.text = text
   }
}
