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
}

protocol NewPostPresenterProtocol: TableViewPresentable {
   var interactor: NewPostInteractorProtocol! {get set}
   var title: String {get}
   func configureView()
   func save(_ completed: @escaping () -> Void)
}

protocol NewPostInteractorProtocol: class {
   func saveNewPost(title: String, image: UIImage, body bodyText: String, _ completed: @escaping () -> Void)
}

protocol NewPostRouterProtocol: class {
   func closeCurrentViewController()
}
