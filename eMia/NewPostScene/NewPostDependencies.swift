//
//  NewPostDependencies.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

class NewPostDependencies: NSObject {

   func configure(_ view: NewPostViewController) {
      let presenter = NewPostPresenter()
      let interactor = NewPostInteractor()
      let router = NewPostRouter()
      let editor = NewPostEditor()
      editor.tableView = view.tableView
      editor.fakeTextField = view.fakeTextField
      editor.viewController = view
      
      view.presenter = presenter
      view.editor = editor
      
      presenter.view = view
      presenter.router = router
      presenter.interactor = interactor
      
      interactor.input = editor
      
      router.view = view
   }
}
