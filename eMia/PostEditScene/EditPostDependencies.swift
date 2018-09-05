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
      let editor = EditPostEditor()
      
      presenter.view = view
      presenter.interactor = interactor
      presenter.router = router
      presenter.post = view.post
      
      editor.view = view
      editor.interactor = interactor
      editor.post = view.post
      editor.tableView = view.tableView
      editor.tvHeightConstraint = view.bottomTableViewConstraint
      editor.activityIndicator = view.activityIndicator
      
      view.presenter = presenter
      view.editor = editor
      
      interactor.presenter = presenter
      interactor.post = view.post
      interactor.input = editor
   }
}
