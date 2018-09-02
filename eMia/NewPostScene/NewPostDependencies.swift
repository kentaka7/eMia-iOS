//
//  NewPostDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostDependencies: NSObject {

   func configure(_ view: NewPostViewController) {
      let presenter = NewPostPresenter()
      let interactor = NewPostInteractor()
      let router = NewPostRouter()
      
      view.presenter = presenter

      presenter.view = view
      presenter.router = router
      presenter.interactor = interactor
      
      router.view = view
   }
}
