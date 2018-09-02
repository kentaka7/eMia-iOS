//
//  NewPostRouter.swift
//  eMia
//
//  Created by Сергей Кротких on 31/08/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

class NewPostRouter: NewPostRouterProtocol {

   weak var view: NewPostViewController!

   deinit {
      Log()
   }

   func closeCurrentViewController() {
      self.view.navigationController?.popViewController(animated: true)
   }
}
