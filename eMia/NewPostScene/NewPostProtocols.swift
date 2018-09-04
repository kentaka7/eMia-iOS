//
//  NewPostProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol NewPostDependenciesProtocol {
   func configure(_ view: NewPostViewController)
}

protocol NewPostViewProtocol: class {
   var presenter: NewPostPresenterProtocol! {get}
   var tableView: UITableView! {get}
   var viewController: UIViewController? {get}
   var fakeTextField: UITextField! {get}
   var saveButton: UIButton! {get}
   var backBarButtonItem: UIBarButtonItem! {get}
   func setUpTitle(text: String)
}

protocol NewPostPresenterProtocol: class {
   var interactor: NewPostInteractorProtocol! {get set}
   func configureView()
   func doneButtonPressed()
   func backButtonPressed()
}

protocol NewPostInteractorProtocol: class {
   func saveNewPost(data: NewPostData, _ completed: @escaping () -> Void)
}

protocol NewPostRouterProtocol: class {
   func closeCurrentViewController()
}
