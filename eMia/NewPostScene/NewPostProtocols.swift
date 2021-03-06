//
//  NewPostProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
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
   func save(_ completed: @escaping () -> Void)
}

protocol NewPostRouterProtocol: class {
   func closeCurrentViewController()
}

protocol NewPostEditorProtocol {
   func configureView()
}

protocol NewPostInteracorInput: class {
   func buildNewPostData() -> NewPostData?
}
