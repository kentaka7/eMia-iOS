//
//  PhotoPostViewController.swift
//  eMia
//
//  Created by Sergey Krotkih on 1/21/18.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

class PhotoPostViewController: UIViewController {

   @IBOutlet weak var imageView: UIImageView!
   public var image: UIImage?

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      imageView.image = image
   }
}
