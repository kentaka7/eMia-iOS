//
//  Register5ViewCell.swift
//  eMia
//

import UIKit

/**
 MyProfile scene.
 User's year birthday definition
 */

protocol YearChangeable {
   var year: Int? {get}
}


class Register5ViewCell: UITableViewCell, YearChangeable {
   
   private let kMinBirthYear = 1900
   private let kMaxBirthYear = 2006
   
   @IBOutlet weak var yearBirthTitleLabel: UILabel!
   @IBOutlet weak var yearPickerView: UIPickerView!

   fileprivate var _year: Int?
   
   var year: Int? {
      return _year
   }
   
   var pickerData = [Int]()
   
   override func awakeFromNib() {
      yearBirthTitleLabel.text = "Year birth".localized

      configure(yearBirthTitleLabel)
      configure(yearPickerView)
   }

   private func configure(_ view: UIView) {
      switch view {
      case yearPickerView:
         yearPickerView.delegate = self
         yearPickerView.dataSource = self
         
         yearPickerView.tintColor = GlobalColors.kBrandNavBarColor
         
         for year in (kMinBirthYear...kMaxBirthYear).reversed() {
            pickerData.append(year)
         }
      case yearBirthTitleLabel:
         yearBirthTitleLabel.textColor = GlobalColors.kBrandNavBarColor
      default:
         break
      }
   }
}

extension Register5ViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return pickerData.count
   }
   
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }
   
   // The number of columns of data
   func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
      return 1
   }
   
   // The data to return for the row and component (column) that's being passed in
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return String(pickerData[row])
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      _year = pickerData[row]
   }
   
}

//

extension Register5ViewCell {

   func setYear(_ year: Int) {
      if let row = pickerData.index(of: year) {
         _year = pickerData[row]
         yearPickerView.selectRow(row, inComponent: 0, animated: false)
      }
   }
}
