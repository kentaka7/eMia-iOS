//
//  MyProfile2ViewCell.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/20/17.
//  Copyright © 2017 Coded I/S. All rights reserved.
//

import UIKit

/**
 Settings menu item for text label
 */

class MyProfile2ViewCell: UITableViewCell {
   
   @IBOutlet weak var titleLabel: UILabel!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      configure(titleLabel)
   }

   private func configure(_ view: UIView) {
      switch view {
      case titleLabel:
         titleLabel.textColor = GlobalColors.kBrandNavBarColor
      default:
         break
      }
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
}

// Update View. Important: this View doesn't know about Model

extension MyProfile2ViewCell: ShortMenuViewItemProtocol {

   func setTitle(_ text: String?) {
      titleLabel.text = text
   }

   func setImage(_ image: UIImage?) {
   }
}
