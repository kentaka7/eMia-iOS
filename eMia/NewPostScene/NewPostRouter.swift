//
//  NewPostRouter.swift
//  eMia
//
//  Created by Sergey Krotkih on 31/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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
