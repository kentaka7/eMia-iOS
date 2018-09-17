//
//  EditPostDependencies.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class EditPostDependencies: NSObject {

   func configure(_ view: EditPostViewController) {
      let post = view.post
      let presenter = EditPostPresenter()
      let interactor = EditPostInteractor()
      let router = EditPostRouter()
      let editor = EditPostEditor()
      let viewModel = EditPostViewModel(post: post!)
      
      presenter.view = view
      presenter.interactor = interactor
      presenter.router = router
      presenter.post = post
      
      editor.view = view
      editor.interactor = interactor
      editor.post = post
      editor.tableView = view.tableView
      editor.tvHeightConstraint = view.bottomTableViewConstraint
      editor.activityIndicator = view.activityIndicator
      editor.viewModel = viewModel

      viewModel.view = editor
      
      view.presenter = presenter
      view.editor = editor
      
      interactor.presenter = presenter
      interactor.post = post
      interactor.input = editor
   }
}
