//
//  Register3ViewCell.swift
//  eMia
//

import UIKit

/**
 MyProfile scene.
 User's address (municipality) definition
 */

class Register3ViewCell: UITableViewCell {
   
   @IBOutlet weak var addressTitleLabel: UILabel!
   @IBOutlet weak var pickerView: UIPickerView!
   @IBOutlet weak var whereAmIButton: UIButton!
   
   weak var locationAgent: LocationComputing!
   private var municipalityPicker: MunicipalityPicker!
   
   var address: String? {
      return municipalityPicker.municipality?.0
   }

   override func awakeFromNib() {
      configure(addressTitleLabel)
//      configure(whereAmIButton)
      configure(pickerView)
   }

   @IBAction func whereAmIButtonPressed(_ sender: Any) {
      locationAgent.calculateWhereAmI()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case addressTitleLabel:
         configureAddressTitle()
      case whereAmIButton:
         configureLocationButton()
      case pickerView:
         municipalityPicker = MunicipalityPicker(pickerView: pickerView)
      default:
         break
      }
   }
   
   private func configureAddressTitle() {
      addressTitleLabel.text = "Choose your municipality".localized
      addressTitleLabel.textColor = GlobalColors.kBrandNavBarColor
   }
   
   private func configureLocationButton() {
      whereAmIButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
   }
}

//

extension Register3ViewCell {
   func setAddress(_ address: String?) {
      municipalityPicker.configure(for: address)
   }
}
