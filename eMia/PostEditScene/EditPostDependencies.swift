//
//  EditPostDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class EditPostDependencies: NSObject {

   func configure(_ view: EditPostViewController) {
      let presenter = EditPostPresenter()
      let interactor = EditPostInteractor()
      let router = EditPostRouter()
      let keyboardController = KeyboardController()
      let fakeField = FakeFieldController()

      presenter.view = view
      presenter.interactor = interactor
      presenter.keyboardController = keyboardController
      presenter.fakeField = fakeField
      presenter.router = router
      
      view.presenter = presenter
      
      interactor.presenter = presenter
   }
}
