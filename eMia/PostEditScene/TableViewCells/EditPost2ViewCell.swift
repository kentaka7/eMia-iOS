//
//  EditPost2ViewCell.swift
//  eMia
//

import UIKit

// Body text. variavle height table view cell!

class EditPost2ViewCell: UITableViewCell, ForPostConfigurable {

   @IBOutlet weak var bodyTextView: UITextView!

   override func awakeFromNib() {
      configureTextBody()
   }

   func configureView(for post: PostModel) -> CGFloat {
      bodyTextView.text = post.body
      bodyTextView.sizeToFit()
      return bodyTextView.frame.height
   }
   
   private func configureTextBody() {
      bodyTextView.translatesAutoresizingMaskIntoConstraints = false
      bodyTextView.isScrollEnabled = false
   }
   
}
