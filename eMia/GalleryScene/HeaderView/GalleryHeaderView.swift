//
//  GalleryHeaderView.swift
//  eMia
//

import UIKit

class GalleryHeaderView: UICollectionReusableView {

    @IBOutlet weak var title: UILabel!
    
    func update(with model: String) {
        title.text = model
    }
   
   override func awakeFromNib() {
      self.backgroundColor = GlobalColors.kBrandNavBarColor
      title.textColor = UIColor.white
   }
   
}
