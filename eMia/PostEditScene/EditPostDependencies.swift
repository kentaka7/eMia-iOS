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

   static func configure(view: EditPostViewController, post: PostModel, tableView: UITableView, activityIndicator: NVActivityIndicatorView, fakeTextField: UITextField) {
      let keyboardController = KeyboardController()
      let presenter = EditPostPresenter()
      presenter.post = post
      presenter.activityIndicator = activityIndicator
      presenter.tableView = tableView
      presenter.fakeTextField = fakeTextField
      view.presenter = presenter
      view.keyboardController = keyboardController
   }
}
