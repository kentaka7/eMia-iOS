//
//  PhotoPostViewController.swift
//  eMia
//
//  Created by Sergey Krotkih on 1/21/18.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class PhotoPostViewController: UIViewController {

   @IBOutlet weak var imageView: UIImageView!
   public var image: UIImage?

   override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      imageView.image = image
   }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
