//
//  EditPostRouter.swift
//  eMia
//
//  Created by Sergey Krotkih on 31/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

class EditPostRouter: EditPostRouterProtocol {

   weak var view: EditPostViewController!

   deinit {
      Log()
   }

   func closeCurrentViewController() {
      self.view.navigationController?.popViewController(animated: true)
   }
}
