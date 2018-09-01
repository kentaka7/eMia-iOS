//
//  EditPostProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

protocol EditPostViewProtocol: class {
   var presenter: EditPostPresenterProtocol! {get set}
   var view: UIView! { get }
   var post: PostModel! {get}
   var tableView: UITableView! {get}
   var activityIndicator: NVActivityIndicatorView! {get}
   var bottomTableViewConstraint: NSLayoutConstraint! {get}
   var backBarButtonItem: UIBarButtonItem! {get}
   func close()
}

protocol EditPostPresenterProtocol: class, TableViewPresentable {
   var title: String {get}
   func configure()
   func updateView()
}

protocol EditPostInteractorProtocol: class {

}

protocol EditPostRouterProtocol: class {
   func closeScene()
}
