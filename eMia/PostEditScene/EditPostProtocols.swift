//
//  EditPostProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

protocol EditPostDependenciesProtocol {
   func configure(_ view: EditPostViewController)
}

protocol EditPostViewProtocol: class {
   var presenter: EditPostPresenterProtocol! {get set}
   var view: UIView! { get }
   var post: PostModel! {get}
   var tableView: UITableView! {get}
   var activityIndicator: NVActivityIndicatorView! {get}
   var bottomTableViewConstraint: NSLayoutConstraint! {get}
   func setUpTitle(text: String)
   var backBarButtonItem: UIBarButtonItem! {get}
}

protocol EditPostPresenterProtocol: class {
   func configure()
   func updateView()
   func didUpdateComments()
   func didAddComment()
   func closeCurrentViewController()
}

protocol EditPostInteractorProtocol: class {
   var presenter: EditPostPresenterProtocol! {get}
   func configure()
   func updateView()
   func didUpdateComments()
   func didAddComment()
   
   func sendComment(_ text: String, completion: @escaping () -> Void)
}

protocol EditPostRouterProtocol: class {
   func closeCurrentViewController()
}

protocol EditPostEditorProtocol: class {
   func configure()
}

protocol EditPostInteractorInputProtocol: class {
   func updateView()
   func didUpdateComments()
   func didAddComment()
}
