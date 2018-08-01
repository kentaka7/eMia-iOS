//
//  NewPostDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostDependencies: NSObject {

   static func configure(view: NewPostViewController, tableView: UITableView, fakeTextField: UITextField) {
      let presenter = NewPostPresenter()
      let interactor = NewPostInteractor()
      presenter.interactor = interactor
      presenter.tableView = tableView
      presenter.fakeTextField = fakeTextField
      presenter.viewController = view
      view.presenter = presenter
   }
}
