//
//  EditPostViewController.swift
//  eMia
//

import UIKit
import NVActivityIndicatorView

class EditPostViewController: UIViewController, EditPostViewProtocol {

   var presenter: EditPostPresenterProtocol!
   weak var post: PostModel!
   
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
   @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
   
   private let configurator = EditPostDependencies()

   // MARK: View lifecycle
   override func viewDidLoad() {
      super.viewDidLoad()

      Appearance.customize(viewController: self)

      configurator.configure(self)
      presenter.configure()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      presenter.updateView()
   }
}
