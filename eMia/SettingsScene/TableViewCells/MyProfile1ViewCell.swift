//
//  MyProfile1ViewCell.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/20/17.
//  Copyright © 2017 Coded I/S. All rights reserved.
//

import UIKit

/**
   Settings menu item for "My Profile"
 */

class MyProfile1ViewCell: UITableViewCell, SettingOutputProtocol {
   
   @IBOutlet weak var avatarBackgroundView: UIView!
   @IBOutlet weak var avatarImageView: UIImageView!
   @IBOutlet weak var titleLabel: UILabel!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      configure()
   }

   private func configure() {
      configure(titleLabel)
      configure(avatarBackgroundView)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case titleLabel:
         titleLabel.textColor = GlobalColors.kBrandNavBarColor
      case avatarBackgroundView:
         avatarBackgroundView.setAsCircle()
      default:
         break
      }
   }
   
   func setupUserPhoto(image: UIImage?) {
      self.avatarImageView.image = image
   }

   func setupUserName(text: String?) {
      titleLabel.text = text
   }
}
